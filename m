From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCHv3 net-next 08/15] nfp: add BPF to NFP code translator
Date: Thu, 15 Sep 2016 08:53:16 +0100
Message-ID: <20160915085316.7baa07cd@jkicinski-Precision-T1700>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
        <1473879623-15382-9-git-send-email-jakub.kicinski@netronome.com>
        <20160914231510.GC60248@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl,
        David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36006 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759045AbcIOIBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 04:01:35 -0400
Received: by mail-wm0-f49.google.com with SMTP id b187so83292230wme.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 01:01:35 -0700 (PDT)
In-Reply-To: <20160914231510.GC60248@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 14 Sep 2016 16:15:11 -0700, Alexei Starovoitov wrote:
> On Wed, Sep 14, 2016 at 08:00:16PM +0100, Jakub Kicinski wrote:
> > Add translator for JITing eBPF to operations which
> > can be executed on NFP's programmable engines.
> > 
> > Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> > ---
> > v3:
> >  - don't clone the program for the verifier (no longer needed);
> >  - temporarily add a local copy of macros from bitfield.h.  
> 
> so what's the status of that other patch? which tree is it going through?

It's in wireless-drivers-next, Kalle says it should be landing in
net-next early next week.

> Does it mean we'd have to wait till after the merge window? :(
> That would be sad, since it looks like it almost ready.

If it's OK with everyone I was hoping I could have that small local copy
of the macros until bitfield.h gets propagated and then we don't have
to wait :S

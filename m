From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv3 net-next 08/15] nfp: add BPF to NFP code translator
Date: Wed, 14 Sep 2016 16:15:11 -0700
Message-ID: <20160914231510.GC60248@ast-mbp.thefacebook.com>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
 <1473879623-15382-9-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34183 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752008AbcINXPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 19:15:16 -0400
Received: by mail-pa0-f68.google.com with SMTP id vz6so1311765pab.1
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 16:15:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473879623-15382-9-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 08:00:16PM +0100, Jakub Kicinski wrote:
> Add translator for JITing eBPF to operations which
> can be executed on NFP's programmable engines.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
> v3:
>  - don't clone the program for the verifier (no longer needed);
>  - temporarily add a local copy of macros from bitfield.h.

so what's the status of that other patch? which tree is it going through?
Does it mean we'd have to wait till after the merge window? :(
That would be sad, since it looks like it almost ready.

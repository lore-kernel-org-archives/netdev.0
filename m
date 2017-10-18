From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: using verifier to ensure a BPF program uses certain metadata?
Date: Wed, 18 Oct 2017 10:42:55 -0700
Message-ID: <20171018174253.sozuxdyfusixc5sx@ast-mbp>
References: <1508139524.10607.25.camel@sipsolutions.net>
 <20171017225806.b5xubolkyocfgnjc@ast-mbp>
 <1508309791.2674.1.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        linux-wireless <linux-wireless@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:49522 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdJRRm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:42:58 -0400
Content-Disposition: inline
In-Reply-To: <1508309791.2674.1.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 08:56:31AM +0200, Johannes Berg wrote:
> > > Now, I realize that people could trivially just work around this in
> > > their program if they wanted, but I think most will take the
> > > reminder
> > > and just implement
> > > 
> > >     if (ctx->is_data_ethernet)
> > >         return DROP_FRAME;
> > > 
> > > instead, since mostly data frames will not be very relevant to
> > > them.
> > > 
> > > What do you think?
> > 
> > sounds fine and considering new verifier ops after Jakub refactoring
> > a check that is_data_ethernet was accessed would fit nicely.
> > Without void** hack.
> 
> Ok, thanks! I'll have to check what Jakub is doing there, do you have a
> pointer to that refactoring?

something similar to
commit 4f9218aaf8a4 ("bpf: move knowledge about post-translation offsets out of verifier")

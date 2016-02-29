From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] net: remove skb_sender_cpu_clear()
Date: Mon, 29 Feb 2016 11:30:33 -0800
Message-ID: <1456774233.648.91.camel@edumazet-ThinkPad-T530>
References: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
	 <56D492E7.4060900@iogearbox.net>
	 <CAM_iQpUtGbSnvV3Zi74Q5DsZBAAFGZyvjkkeBRciHxwTm4GCEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33329 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbcB2Tbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 14:31:36 -0500
Received: by mail-pf0-f182.google.com with SMTP id 124so35734423pfg.0
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 11:31:36 -0800 (PST)
In-Reply-To: <CAM_iQpUtGbSnvV3Zi74Q5DsZBAAFGZyvjkkeBRciHxwTm4GCEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On lun., 2016-02-29 at 10:55 -0800, Cong Wang wrote:
> On Mon, Feb 29, 2016 at 10:50 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> > On 02/28/2016 05:19 AM, Cong Wang wrote:
> >>
> >> After commit 52bd2d62ce67 ("net: better skb->sender_cpu and skb->napi_id
> >> cohabitation")
> >> skb_sender_cpu_clear() becomes empty and can be removed.
> >>
> >> Cc: Eric Dumazet <edumazet@google.com>
> >> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> >
> >
> > Wasn't the intention to keep this helper as a marker when packet
> > crosses domains from RX to TX, see discussion here:
> >
> >   https://patchwork.ozlabs.org/patch/527167/
> >
> > Maybe better to rename it and add a comment into the helper to
> > make the intention more clear?
> 
> Since when we need an empty function to mark some call path?
> Isn't this supposed to be done by comments or documents?
> 
> BTW, I myself even don't think we need any comment, people
> who touches it should understand it.

I have no objections for this patch.

If we keep the helper, a better name would be needed anyway.

From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
 of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 19:23:18 +0100
Message-ID: <20110118182318.GB4202@del.dom.local>
References: <20110118172340.GB1843@del.dom.local>
 <AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jamal <hadi@cyberus.ca>, David Miller <davem@davemloft.net>,
	pablo@netfilter.org, arthur.marsh@internode.on.net,
	jengelh@medozas.de, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Alessandro Suardi <alessandro.suardi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:56049 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943Ab1ARSXZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 13:23:25 -0500
Received: by ewy5 with SMTP id 5so3486187ewy.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 10:23:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <AANLkTikUPRfYupw1-Py5mHeN+pFv-zMKhmK3DKixxsH4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 18, 2011 at 07:10:35PM +0100, Alessandro Suardi wrote:
> On Tue, Jan 18, 2011 at 6:23 PM, Jarek Poplawski <jarkao2@gmail.com> =
wrote:
> > [PATCH] netlink: Fix possible NLM_F_DUMP misuse in genetlink
> >
> > NLM_F_DUMP flags should be applied to GET requests only, eg. rtnetl=
ink
> > tests message type to verify this. Since genetlink can't do the sam=
e
> > use "practical" test for ops->dumpit (assuming NEW request won't be
> > mixed with GET).
> >
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > Cc: Jan Engelhardt <jengelh@medozas.de>
> > Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> > Cc: Jamal Hadi Salim <hadi@cyberus.ca>
> > ---
> > Not for stable before testing!
> >
> > diff -Nurp a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> > --- a/net/netlink/genetlink.c =A0 2011-01-18 16:58:16.000000000 +01=
00
> > +++ b/net/netlink/genetlink.c =A0 2011-01-18 17:08:43.000000000 +01=
00
> > @@ -519,15 +519,16 @@ static int genl_rcv_msg(struct sk_buff *
=2E..
> 2.6.37-git18 + netlink revert + this patch
>  - fixes Avahi
>  - breaks acpid

Well, then fixing genetlink needs more than this and I withdraw this
patch. Anyway, netlink revert is IMHO needed to prevent the regression.

=2E..
> If more debugging/testing is needed, do ping me. Thanks,

Many thanks for such a fast response!
Jarek P.

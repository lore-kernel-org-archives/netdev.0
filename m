From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv3, ipsec-next] xfrm: Do not parse 32bits compiled xfrm
 netlink msg on 64bits host
Date: Tue, 3 Feb 2015 13:24:32 +0100
Message-ID: <20150203122432.GV13046@secunet.com>
References: <1422349230-17394-1-git-send-email-fan.du@intel.com>
 <54CA0B9F.8080104@6wind.com>
 <20150202084443.GS13046@secunet.com>
 <54CF3D3A.5040607@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>,
	<fengyuleidian0615@gmail.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44808 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbbBCMYg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 07:24:36 -0500
Content-Disposition: inline
In-Reply-To: <54CF3D3A.5040607@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2015 at 10:02:50AM +0100, Nicolas Dichtel wrote:
> Le 02/02/2015 09:44, Steffen Klassert a =E9crit :
> >On Thu, Jan 29, 2015 at 11:29:51AM +0100, Nicolas Dichtel wrote:
> [snip]
> >>
> >>The point I try to make is that patching userland apps allows to us=
e xfrm on a
> >>32bits userland / 64bits kernel.
> >
> >Ugh, I did not know that this is used that way. Which applications d=
o this?
> >So the situation is worse than I thought. What happens to such appli=
cations
> >if we add a compat layer in the kernel? I'd guess they will break, r=
ight?
> A compat layer will be perfect. I just wanted to highlight the fact t=
hat without
> this patch, it's possible to have a workaround to use netlink-xfrm an=
d after it,
> it will be impossible.

You did not answer my question about the applications that do this.
If it is just possible, but there are no actual users, we should
apply this patch as soon as possible to avoid any abuse of this ABI.

I tend to apply this patch unless you can come up with a real world
application that will break if we do so.

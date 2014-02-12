From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Thu, 13 Feb 2014 00:35:18 +0100
Message-ID: <20140212233518.GG11150@order.stressinduktion.org>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com> <20140207222840.GD16198@order.stressinduktion.org> <CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com> <20140208005843.GE16198@order.stressinduktion.org> <CALnjE+qiRbLWBJyhig7DFETRLRgAZHqJqUEYGVuJ6nXc7cPguw@mail.gmail.com> <20140211021150.GB11150@order.stressinduktion.org> <CALnjE+r5zUs0GKUESoum2YumjbfU2XKhDjjcoWUv2D8yiGEYkA@mail.gmail.com> <52FB3FC1.8080603@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50685 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaBLXfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 18:35:19 -0500
Content-Disposition: inline
In-Reply-To: <52FB3FC1.8080603@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 10:32:49AM +0100, Nicolas Dichtel wrote:
> Le 12/02/2014 05:26, Pravin Shelar a =C3=A9crit :
> >On Mon, Feb 10, 2014 at 6:11 PM, Hannes Frederic Sowa
> >I am not sure why the caller can not just set skb->local_df before
> >calling iptunnel_xmit() rather than passing extra arg to this
> >function?
> >There are not that many caller of this function.
> The benefit is that it ensures that future callers will think about t=
his=20
> point
> ;-)

Exactly, I thought about adding skb->local_df =3D 0 to all the tunnel c=
ode but
wanted to force users of the interface to think about the parameter and=
 its
consequences.

Greetings,

  Hannes

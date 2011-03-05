From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6 3/8] net: get rid of multiple bond-related
 netdevice->priv_flags
Date: Sat, 05 Mar 2011 14:37:42 +0000
Message-ID: <1299335862.4277.99.camel@localhost>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
	 <1299320969-7951-4-git-send-email-jpirko@redhat.com>
	 <4D72453F.10909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net
To: Nicolas de =?ISO-8859-1?Q?Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:10636 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab1CEOhr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 09:37:47 -0500
In-Reply-To: <4D72453F.10909@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-03-05 at 15:14 +0100, Nicolas de Peslo=C3=BCan wrote:
> Le 05/03/2011 11:29, Jiri Pirko a =C3=A9crit :
[...]
> > --- a/include/linux/if.h
> > +++ b/include/linux/if.h
> > @@ -60,21 +60,17 @@
> >   #define IFF_802_1Q_VLAN 0x1             /* 802.1Q VLAN device.   =
       */
> >   #define IFF_EBRIDGE	0x2		/* Ethernet bridging device.	*/
> >   #define IFF_SLAVE_INACTIVE	0x4	/* bonding slave not the curr. act=
ive */
> > -#define IFF_MASTER_8023AD	0x8	/* bonding master, 802.3ad. 	*/
> > -#define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
> > -#define IFF_BONDING	0x20		/* bonding master or slave	*/
> > -#define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
> > -#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
> > -#define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use=
 */
> > -#define IFF_WAN_HDLC	0x200		/* WAN HDLC device		*/
> > -#define IFF_XMIT_DST_RELEASE 0x400	/* dev_hard_start_xmit() is all=
owed to
> > +#define IFF_BONDING	0x8		/* bonding master or slave	*/
> > +#define IFF_ISATAP	0x10		/* ISATAP interface (RFC4214)	*/
> > +#define IFF_WAN_HDLC	0x20		/* WAN HDLC device		*/
> > +#define IFF_XMIT_DST_RELEASE 0x40	/* dev_hard_start_xmit() is allo=
wed to
> >   					 * release skb->dst
> >   					 */
>=20
> Why did you changed those values? Aren't those exposed to userland? J=
ust removing the unused one=20
> sounds good to me.
[...]

Look just one line further up:

/* Private (from user) interface flags (netdevice->priv_flags). */

Maybe they should have a prefix IFPF_ instead of IFF_ though.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


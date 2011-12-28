From: <Narendra_K@Dell.com>
Subject: RE: bonding device in balance-alb mode shows packet loss in kernel
 3.2-rc6
Date: Tue, 27 Dec 2011 23:25:27 -0800
Message-ID: <E31FB011129F30488D5861F38390491520C52BCE6C@BLRX7MCDC201.AMER.DELL.COM>
References: <E31FB011129F30488D5861F38390491520C52BCC8B@BLRX7MCDC201.AMER.DELL.COM>
 <4EFA22D1.8050807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <fubar@us.ibm.com>
To: <nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxippc101.us.dell.com ([143.166.85.207]:62821 "EHLO
	ausxippc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab1L1HZa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 02:25:30 -0500
In-Reply-To: <4EFA22D1.8050807@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Nicolas de Peslo=FCan
> Sent: Wednesday, December 28, 2011 1:26 AM
> To: K, Narendra
> Cc: netdev@vger.kernel.org; fubar@us.ibm.com
> Subject: Re: bonding device in balance-alb mode shows packet loss in =
kernel
> 3.2-rc6
>=20
> Le 27/12/2011 15:31, Narendra_K@Dell.com a =E9crit :
> > Hello,
> >
> > On kernel version 3.2-rc6, when a bonding device is configured in
> > 'balance-alb' mode, ping reported packet losses. By looking at
> > protocol trance, it seemed like the lost packets had the destinatio=
n MAC id
> of inactive slave.
> >
>=20
> [snip]
>=20
> Can you provide the output of the following command?
>=20
> grep . /sys/classs/net/bond0/bonding/*

Hi, thanks for the response. Please find the output here -

# grep . /sys/class/net/bond0/bonding/*
/sys/class/net/bond0/bonding/active_slave:em2
/sys/class/net/bond0/bonding/ad_select:stable 0
/sys/class/net/bond0/bonding/all_slaves_active:0
/sys/class/net/bond0/bonding/arp_interval:0
/sys/class/net/bond0/bonding/arp_validate:none 0
/sys/class/net/bond0/bonding/downdelay:0
/sys/class/net/bond0/bonding/fail_over_mac:none 0
/sys/class/net/bond0/bonding/lacp_rate:slow 0
/sys/class/net/bond0/bonding/miimon:100
/sys/class/net/bond0/bonding/mii_status:up
/sys/class/net/bond0/bonding/min_links:0
/sys/class/net/bond0/bonding/mode:balance-alb 6
/sys/class/net/bond0/bonding/num_grat_arp:1
/sys/class/net/bond0/bonding/num_unsol_na:1
/sys/class/net/bond0/bonding/primary_reselect:always 0
/sys/class/net/bond0/bonding/queue_id:em2:0 em3:0 em4:0
/sys/class/net/bond0/bonding/resend_igmp:1
/sys/class/net/bond0/bonding/slaves:em2 em3 em4
/sys/class/net/bond0/bonding/updelay:0
/sys/class/net/bond0/bonding/use_carrier:1
/sys/class/net/bond0/bonding/xmit_hash_policy:layer2 0

With regards,
Narendra K

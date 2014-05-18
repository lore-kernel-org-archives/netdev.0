From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/12] cdc_ncm: add buffer tuning and stats
 using ethtool
Date: Sun, 18 May 2014 18:08:12 -0400 (EDT)
Message-ID: <20140518.180812.1049323503041824106.davem@davemloft.net>
References: <20140518011917.11270.qmail@stuge.se>
	<alpine.LNX.2.03.1405181155310.7743@gmail.com>
	<87vbt3m98p.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: peter@stuge.se, mrkiko.rs@gmail.com, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, alexey.orishko@gmail.com,
	oliver@neukum.org, David.Laight@aculab.com
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43287 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752334AbaERWIR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2014 18:08:17 -0400
In-Reply-To: <87vbt3m98p.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sun, 18 May 2014 16:50:30 +0200

> I could be wrong, but my impression is that the userspace API
> preferences for network devices are
>=20
>  1. ethtool
>  2. sysfs
>  3. module param
>  ..
>  99. ioctl

I would swap module param and ioctl, module params are the least
desirable interface and strongly discouraged.

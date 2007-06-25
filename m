From: =?ISO-8859-15?Q?Siim_P=F5der?= <siim@p6drad-teel.net>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 17:45:19 +0300
Message-ID: <467FD4FF.2000104@p6drad-teel.net>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com> <467FBFE2.7050605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [194.126.108.29] ([194.126.108.29]:60350 "EHLO
	localhost.localdomain" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752339AbXFZFNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2007 01:13:25 -0400
Received: from localhost.skype.net ([127.0.0.1] ident=siim)
	by localhost.localdomain with esmtp (Exim 4.67)
	(envelope-from <siim@p6drad-teel.net>)
	id 1I2poe-0007YI-5I
	for netdev@vger.kernel.org; Mon, 25 Jun 2007 17:45:20 +0300
In-Reply-To: <467FBFE2.7050605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yo!

Patrick McHardy wrote:
> OBATA Noboru wrote:
>> Make TCP_RTO_MAX a variable, and allow a user to change it via a
>> new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
>> then guarantee TCP retransmission to be more controllable, say,
>> at least once per 10 seconds, by setting it to 10.  This is
>> quite helpful on failover-capable network devices, such as an
>> active-backup bonding device.  On such devices, it is desirable
>> that TCP retransmits a packet shortly after the failover, which
>> is what I would like to do with this patch.  Please see
>> Background and Problem below for rationale in detail.
>=20
> Would it make sense to do this per route?

To only do it per route would reduce it's usefulness with dynamic
routing as routing daemons would probably have trouble supporting it.

Siim P=F5der

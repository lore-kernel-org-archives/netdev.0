From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: Query on usage of Netlink
Date: Fri, 08 Oct 2010 12:14:44 +0200
Message-ID: <1b4c783a02b46d7da4e308699a41856c@chewa.net>
References: <20101008085056.GA13091@bnru01.bnr.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, srinidhi.kasagar@stericsson.com,
	linus.walleij@stericsson.com, sudeep.divakaran@stericsson.com,
	gulshan.karmani@stericsson.com
To: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:51994 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757074Ab0JHKOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 06:14:45 -0400
In-Reply-To: <20101008085056.GA13091@bnru01.bnr.st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 8 Oct 2010 14:21:28 +0530, Kumar SANGHVI=0D
<kumar.sanghvi@stericsson.com> wrote:=0D
> We have a requirement where-in we want to communicate the status of=0D
> modem (whether modem is online or offline) from linux driver to=0D
> user-space components. So that user-space components stop sending dat=
a=0D
> to linux driver for communicating with modem, in case modem goes=0D
> offline.=0D
=0D
Is the modem control state machine in kernel space, as for say, 802.11=0D
devices?=0D
=0D
> We have decided to use the netlink mechanism to achieve this. We inte=
nd=0D
> to send an integer value, defined in enum, to user-space indicating t=
he=0D
> current modem status.=0D
(...)=0D
> Or should we define a custom Netlink type in include/linux/netlink.h?=
=0D
=0D
Did you consider using kobject and uevents (which are internally runnin=
g on=0D
top of Netlink)?=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis


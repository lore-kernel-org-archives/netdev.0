From: David Miller <davem@davemloft.net>
Subject: Re: AF_KEY extended xfrm_state selector handling
Date: Fri, 20 Oct 2006 02:52:06 -0700 (PDT)
Message-ID: <20061020.025206.71090291.davem@davemloft.net>
References: <200610191626.k9JGQ7x4014606@gateplz.comstar.cz>
	<1161305972.5034.58.camel@jzny2>
	<00b501c6f425$a0325be0$2303a8c0@mruzicka>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18078
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751694AbWJTJwI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 05:52:08 -0400
To: michal.ruzicka@comstar.cz
In-Reply-To: <00b501c6f425$a0325be0$2303a8c0@mruzicka>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michal R=F9=BEi=E8ka <michal.ruzicka@comstar.cz>
Date: Fri, 20 Oct 2006 10:56:13 +0200

> - Do you suggest that there is another IKE implemetation for Linux 2.=
6 IPSec=20
> stack which uses netlink socket (XFRM) for kernel communication? If s=
o,=20
> would you please point me to it?

OpenSWAN is an IKE implementation that works with Linux and uses XFRM.

It actually uses AF_KEY too, but only to probe the list of available
crypto algorithms.

From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [Bonding-devel] 2.6.29 regression? Bonding tied to IPV6 in
 29-rc5
Date: Wed, 4 Mar 2009 12:46:37 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0903041244400.31513@fbirervta.pbzchgretzou.qr>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <200902172117.22671.arvidjaar@mail.ru> <499B19AF.1000003@hp.com> <16929.1234904788@death.nxdomain.ibm.com>
 <499B30DC <21405.1234909454@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Brian Haley <brian.haley@hp.com>,
	Andrey Borzenkov <arvidjaar@mail.ru>, "J.A. Magall"@us.ibm.com,
	=?UTF-8?Q?=C3=B3n?= <jamagallon@ono.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, bonding-devel@lists.sourcefor
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:57262 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753611AbZCDLql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 06:46:41 -0500
In-Reply-To: <21405.1234909454@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tuesday 2009-02-17 23:24, Jay Vosburgh wrote:
>Brian Haley <brian.haley@hp.com> wrote:
>
>	I don't see any reason to change the IPv4 bits;
>
>there won't ever be a case of ipv4 not being loaded,

I would not be so sure of that.

>>> 	To answer your question, I have come across this (aliasing ipv6
>>> to nothing in modprobe.conf to disable IPv6) from time to time, but
>>> didn't think of it when the NA code was added to bonding.
>>
>>So I guess I'll start hacking the above, unless someone has a better
>>suggestion.
>
>	Well, I think this is pretty heinous, but I don't have a better
>idea at the moment.

IMO, a better solution could be to add a dummy ipv6 module that returns 
-EOPNOTSOPP or appropriate for most calls.

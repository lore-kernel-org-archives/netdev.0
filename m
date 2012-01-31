From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH V2] net/sched: =?UTF-8?Q?sch=5Fplug=20-=20Queue=20traf?=  =?UTF-8?Q?fic=20until=20an=20explicit=20release=20command?=
Date: Tue, 31 Jan 2012 16:25:06 +0100
Message-ID: <6790d1d5d8aa930222bbfc2ef6a9d48e@localhost>
References: <1327823619-29274-1-git-send-email-rshriram@cs.ubc.ca>
 <1327934756.2243.3.camel@mojatatu>
 <313929ea4dca3c8fd6948797e03121a8@localhost>
 <B99410E5-6E69-425A-913D-272058765A68@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, " " <netdev@vger.kernel.org>,
	Brendan Cully <brendan@cs.ubc.ca>
To: Shriram Rajagopalan <rshriram@cs.ubc.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:49051 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753506Ab2AaPZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 10:25:09 -0500
In-Reply-To: <B99410E5-6E69-425A-913D-272058765A68@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 30 Jan 2012 08:47:45 -0800, Shriram Rajagopalan wrote:



> Could you elaborate a little on the packet-based-unplug ?

> 

> I got your earlier comment on "indefinite unplug" until an explicit

> plug is received. Is that what you mean by packet-based-unplug ?



Sure, imagine a multihop MANET network. Sometimes we have high-priority

crosstraffic in the next hop (router). Due to OLSR traffic information we

know in advance that the next hop is not in the ability to forward our low

priority packets. With this knowledge we can stop (unplug) local generated

and forwarded traffic and if the next hop has enough free bandwidth we can

restart (plug) sending already enqueued packets.



So for us a really simple plug/unplug mechanism is superior. Maybe a

head-drop FIFO based policy for forwarded traffic but I can provide a patch

on top of your patch to implement a head-drop policy.



Hagen

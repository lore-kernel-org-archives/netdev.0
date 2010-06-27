From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Reviewing batman-adv for net/
Date: Mon, 28 Jun 2010 00:27:06 +0200
Message-ID: <20100627222706.GC8285@nuttenaction>
References: <201006260214.06662.sven.eckelmann@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.net
To: Sven Eckelmann <sven.eckelmann@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:57721 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753980Ab0F0W1L convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 18:27:11 -0400
Content-Disposition: inline
In-Reply-To: <201006260214.06662.sven.eckelmann@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Sven Eckelmann | 2010-06-26 02:14:05 [+0200]:

>batman-adv is a meshing protocol currently in drivers/staging/batman-adv. We 
>asked GregKH recently [1] if he thinks that it is ok to send a patch to you 
>for review. He acknowledged that request and now we would like to ask you to 
>review it.
>
>I will send a patch referencing this mail. I hope you find time to send us 
>your opinion and ideas.

Hello Sven,

o Where are the advantages of BATMAN compared to OLSR? OLSR is standardized
  by the IETF which is a great advantage compared to BATMAN. 20 byte IPv4
	header respective 60 byte IPv6 header savings? Network protocol neutrality?
	Where are the differences between BATMAN and 802.11s? Where are the
	similarities? See commit 37c5798968d0ce4 of 802.11s

o Are there any publications which describe the protocol behavior in detail?
  I assume it is a pro-active protocol - similar to standard BATMAN -
	but what about neighbor discovery, TC, HNA and the like? What about multicast
	transport? It is difficult to rate the patchset if no one knowns what the
	intended behavior is.

o The major code is twisted about bookkeeping stuff, configuration aspects and
  so on. The minor codebase is about protocol processing. What about a
	generalized architecture and a userspace implementation of the protocol? And
	communication via netlink sockets.


Cheers, Hagen

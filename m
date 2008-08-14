From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Wed, 13 Aug 2008 19:05:21 -0700 (PDT)
Message-ID: <20080813.190521.224523380.davem@davemloft.net>
References: <48A389DB.9050002@opengridcomputing.com>
	<20080813.183755.72334968.davem@davemloft.net>
	<48A38FEF.6090500@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@opengridcomputing.com, rdreier@cisco.com, rick.jones2@hp.com,
	jgarzik@pobox.com, divy@chelsio.com, kxie@chelsio.com,
	netdev@vger.kernel.org, open-iscsi@googlegroups.com,
	michaelc@cs.wisc.edu, daisyc@us.ibm.com, wenxiong@us.ibm.com,
	bhua@us.ibm.com, dm@chelsio.com, leedom@chelsio.com,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44281
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751164AbYHNCFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 22:05:19 -0400
In-Reply-To: <48A38FEF.6090500@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Wed, 13 Aug 2008 20:52:47 -0500

> How do you envision programming such a device?

There should be no special programming.

> It will need TCP and iSCSI state to have any chance of doing useful
> and productive placement of data.

The card can see the entire TCP stream, it doesn't need anything
more than that.  It can parse every packet header, see what kind
of data transfer is being requested or responded to, etc.

Look, I'm not going to design this whole friggin' thing for you guys.

I've stated clearly what the base requirement is, which is that the
packet is fully processed by the networking stack and that the card
merely does data placement optimizations that the stack can completely
ignore if it wants to.

You have an entire engine in there that can interpret an iSCSI
transport stream, you have the logic to do these kinds of things,
and it can be done without managing the connection on the card.

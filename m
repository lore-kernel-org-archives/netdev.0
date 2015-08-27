From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 0/2] Add new switchdev device class
Date: Thu, 27 Aug 2015 16:25:03 -0700 (PDT)
Message-ID: <20150827.162503.1483675558033304575.davem@davemloft.net>
References: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751752AbbH0XZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 19:25:05 -0400
In-Reply-To: <1440659806-56582-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Thu, 27 Aug 2015 00:16:44 -0700

> Comments?

No fundamental objections from me.

I just want to reiterate one thing I think Jiri said.

There are other kinds of devices which make up this kind of hierarchy.
I can think of two examples involving bonafide ethernet ports.

1) A top-level parent device provides the resources for all of the RX
   and TX queues, which are allocated and divided by the driver down into
   the ethernet ports below.  Example: niu

2) Cards are going to need more than one PCI-E slot to get all of the
   PCI-E lanes necessary to saturate the link.  Two PCI devices
   show up and need to get probed in this scenerio and it would be
   nice to have some object to represent the logical "glueing"
   together of those two devices.

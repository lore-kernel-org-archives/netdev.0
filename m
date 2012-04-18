From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] ehea: do not dereference possible NULL port
Date: Wed, 18 Apr 2012 13:28:37 -0400 (EDT)
Message-ID: <20120418.132837.1291329834032822083.davem@davemloft.net>
References: <1334673715-16338-4-git-send-email-cascardo@linux.vnet.ibm.com>
	<20120417.222912.1038252957653077871.davem@davemloft.net>
	<20120418124252.GA2455@oc1711230544.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab2DRR2q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 13:28:46 -0400
In-Reply-To: <20120418124252.GA2455@oc1711230544.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Wed, 18 Apr 2012 09:42:52 -0300

> However, at first, I suspected this interrupt may have come from some
> other port from ehca, for example, considering a possible firmware bug.
> After more investigation, I found out that the real problem was some
> physical ports in some odd states, that caused the IRQs before the ports
> were enabled. Note that this is not really supposed to happen.

It doesn't matter how it happens from the hardware side.

What matters is that you should not register the IRQ handler
at all until all the datastructures are properly setup.

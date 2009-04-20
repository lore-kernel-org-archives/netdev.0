From: Neil Horman <nhorman@tuxdriver.com>
Subject: [RFC]: add tracepoint to net_rx_action to note polling operations
Date: Mon, 20 Apr 2009 07:27:31 -0400
Message-ID: <20090420112731.GD32254@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46537 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754863AbZDTL1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 07:27:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	I was thinking about adding an additional tracepoint to net_rx_action,
right before the call to dev->poll().  One of the things thats missing from my
dropwatch utility is the ability to detect hardware drops, and I was thinking I
could implement that by noting when devices were being polled by napi, and at
that time querying the devices stats.

	I know however, that adding tracepoints isn't always desireable, so I
thought I would solicit opinions here to see if anyone else would find such a
tracepoint usefull, or in the event they had strong objectsions to such a point.

Thanks!
Neil


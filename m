From: Mark Smith <ipng@69706e6720323030352d30312d31340a.nosense.org>
Subject: sk_buff handling in packet handler
Date: Sun, 17 May 2009 10:25:48 +0930
Message-ID: <20090517102548.0a55d5bd.ipng@69706e6720323030352d30312d31340a.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clauder@accedian.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.adam.net.au ([202.136.110.251]:60291 "EHLO
	smtp2.adam.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbZEQAzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 20:55:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Claude,

You could have a look at my Ethernet Configuration Testing Protocol
(ECTP) implementation. I followed what other protocols did regarding
packet/skb handling, and also tried to make it very clear what was
required, as I struggled a bit with similar issues that you are. The
routine to start with is ectp_rcv().

http://lwn.net/Articles/330797/

Regards,
Mark.

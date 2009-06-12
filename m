From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: lots of cpu time spent in skb_copy_bits() in net-next with small
	mtu
Date: Fri, 12 Jun 2009 12:13:20 -0400
Message-ID: <20090612161320.GB4290@neterion.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42668 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbZFLQQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 12:16:24 -0400
Received: from guinness.s2io.com (localhost [127.0.0.1])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 67196201E870
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 12:13:23 -0400 (EDT)
Received: from guinness.s2io.com (142-46-210.147.tel-ott.com [142.46.210.147]) by barracuda.s2io.com with ESMTP id 32t3RcVIoCsRW143 for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 12:13:23 -0400 (EDT)
Received: from neterion.com ([10.16.18.39])
	by guinness.s2io.com (8.12.6/8.12.6) with ESMTP id n5CGDLmd014584
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2009 12:13:22 -0400 (EDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Just a heads up: something in net-next is resulting in lots of cpu time 
being spent in skb_copy_bits() (called from tcp_collapse()) when an ethernet 
interface mtu is lowered to 576 on the source and dest machines running 
netperf.  This behaviour does not appear in 2.6.29.  I'll try to bisect 
it this weekend.

		-ben

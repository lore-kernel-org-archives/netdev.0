From: Sridhar Samudrala <sri@us.ibm.com>
Subject: per connection TCP traffic shaping
Date: Mon, 07 Mar 2011 16:21:50 -0800
Message-ID: <4D75769E.3060406@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:54102 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754248Ab1CHAV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 19:21:58 -0500
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2806qUM028350
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2011 17:06:52 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p280LtHY063634
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2011 17:21:55 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p280JV3H024792
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2011 17:19:31 -0700
Received: from [127.0.0.1] (sig-9-76-209-112.mts.ibm.com [9.76.209.112])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p280JTF2024745
	for <netdev@vger.kernel.org>; Mon, 7 Mar 2011 17:19:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are looking into a scalable way to configure a linux router to shape traffic
on outgoing connections(upto 10000) to (100Kb/s - 1Mb/s) over a 10Gb link.

Can someone point to any scripts that can be used to implement
per-connection traffic shaping using 'tc' and 'iptables'?

Can this be done without having to create a separate tc class/filter for each
connection?

Thanks
Sridhar





From: Ben Greear <greearb@candelatech.com>
Subject: How to increase wifi A-MDU with lots of streaming peers?
Date: Wed, 04 Feb 2015 23:03:54 -0800
Message-ID: <54D315DA.7060504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40948 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589AbbBEHCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 02:02:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose one has an AP that is trying to support 40 or so clients all streaming
video, using http gets to get around 2 seconds worth of data at a time.
The AP's NIC is ath10k, stations are a mix of /n and /ac.

User has control of streaming server and AP, but not clients.

I think from wifi transport side, it would be best if data could be
excessively queued in the wifi AP so that larger A-MPDUs could possibly
be sent.  The streaming server could use large tcp tx socket buffers to
deal with extra latency that the AP's queueing would cause.

First, does this seem sane.

And second, any idea how to go about it?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

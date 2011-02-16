From: Eliot Blennerhassett <linux@audioscience.com>
Subject: AVB QoS  support (IEEE802.1 Qav and Qat)
Date: Thu, 17 Feb 2011 08:51:17 +1300
Message-ID: <4D5C2AB5.8010009@audioscience.com>
References: <4D488D9B.5080409@audioscience.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.clear.net.nz ([203.97.37.64]:55501 "EHLO
	smtp4.clear.net.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063Ab1BPTvU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Feb 2011 14:51:20 -0500
Received: from [192.168.36.2]
 (121-72-250-62.cable.telstraclear.net [121.72.250.62])
 by smtp4.clear.net.nz (CLEAR Net Mail)
 with ESMTP id <0LGQ00LXF75I0S50@smtp4.clear.net.nz> for
 netdev@vger.kernel.org; Thu, 17 Feb 2011 08:51:19 +1300 (NZDT)
In-reply-to: <4D488D9B.5080409@audioscience.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings

Can linux network stacks can support the various protocols required by AVB?
It is not clear to me if it already does, and in any case how the setup
would be accessed?

In particular these two standards and the interaction between them

802.1Qat - Stream Reservation Protocol
802.1Qav - Forwarding and Queuing Enhancements for Time-Sensitive
Streams (approved on Dec 10th, 2009)

Qav requires traffic shaping to smooth the traffic flow in guaranteed
stream class. This is afaik based on 1 packet per stream per 125us

Note that in future (maybe already) there will be hardware assist for
this feature in NIC chips.

-- 
Eliot Blennerhassett
AudioScience Inc.


[1] http://www.ieee802.org/1/pages/avbridges.html
[2]
http://en.wikipedia.org/wiki/Audio_Video_Bridging#Traffic_shaping_for_AV_streams

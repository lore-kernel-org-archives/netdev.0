From: "Phil Hord (hordp)" <hordp@cisco.com>
Subject: RE: [BUG/PATCH] ppp_mppe discards 50% of packets from some servers
Date: Fri, 1 Jun 2012 15:09:10 -0500
Message-ID: <86212E265A665C4E9744E3BB9A6E44D0050A1DD8@XMB-RCD-212.cisco.com>
References: <4FA45809.2020003@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-8.cisco.com ([173.37.86.79]:24979 "EHLO
	rcdn-iport-8.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751804Ab2FAUJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 16:09:12 -0400
Received: from xbh-rcd-301.cisco.com (xbh-rcd-301.cisco.com [72.163.63.8])
	by rcdn-core-6.cisco.com (8.14.5/8.14.5) with ESMTP id q51K9Bux001281
	for <netdev@vger.kernel.org>; Fri, 1 Jun 2012 20:09:11 GMT
Content-class: urn:content-classes:message
In-Reply-To: <4FA45809.2020003@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Having received no replies on this issue, should I assume this is the
wrong place to report it, that I reported it in the wrong format, that
the patch is too hacky for consideration, or no one has time to care
(yet)?

Phil

Please pardon my top-posting...  This MUA sucks.

-----Original Message-----
From: Phil Hord (hordp) 
Sent: Friday, May 04, 2012 6:28 PM
To: netdev@vger.kernel.org
Subject: [BUG/PATCH] ppp_mppe discards 50% of packets from some servers

[BUG] ppp_mppe discards 50% of packets from some servers

[2.] Full description of the problem/report:

When I connect to a server using MPPE, I receive about every other
packet with the FLUSHED bit turned off. These packets are dropped by
ppp_mppe.c just like the SPEC says they should be. I am not able to
maintain tcp connections through the VPN with these packets being
discarded.

I found a patch discussed here:
http://ubuntuforums.org/showthread.php?t=1095189

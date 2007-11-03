From: "Martin J. Bligh" <mbligh@google.com>
Subject: via-rhine driver stalls with: PHY status 786d, resetting...
Date: Sat, 03 Nov 2007 11:30:12 -0700
Message-ID: <472CBE34.1040405@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:40558 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755532AbXKCSaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2007 14:30:20 -0400
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id lA3IUFGR009851
	for <netdev@vger.kernel.org>; Sat, 3 Nov 2007 11:30:15 -0700
Received: from smtp.corp.google.com (spacemonkey3.corp.google.com [192.168.120.116])
	by zps75.corp.google.com with ESMTP id lA3IUEo6004906
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 3 Nov 2007 11:30:14 -0700
Received: from [192.168.0.2] (c-67-170-233-68.hsd1.ca.comcast.net [67.170.233.68])
	(authenticated bits=0)
	by smtp.corp.google.com (8.13.8/8.13.8) with ESMTP id lA3IUDQK017643
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 3 Nov 2007 10:30:14 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux 2.6.23

http://bugzilla.kernel.org/show_bug.cgi?id=9300

Under any sort of traffic load (recursive scp from another box of a 
bunch of mp3s, for instance), I get continuous stalls. Recovers every
time, but is dog slow.

NETDEV WATCHDOG: eth2: transmit timed out
eth2: Transmit timed out, status 0000, PHY status 786d, resetting...
eth2: link up, 100Mbps, full-duplex, lpa 0xCDE1

driver is via-rhine.

Google search indicates this has been a problem since at least 2.4.19 
and 2002 ... can we not fix this somehow? I have an e1000 card in this
box too, but that has similar issues ;-(

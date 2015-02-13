From: yzhu1 <Yanjun.Zhu@windriver.com>
Subject: If bridge have no sub-interfaces, it's status may be still with 'RUNNING'
Date: Fri, 13 Feb 2015 17:57:45 +0800
Message-ID: <54DDCA99.4040401@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"Wu, Kuaikuai" <Kuaikuai.Wu@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:38758 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbbBMJ5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 04:57:37 -0500
Received: from ALA-HCA.corp.ad.wrs.com (ala-hca.corp.ad.wrs.com [147.11.189.40])
	by mail1.windriver.com (8.14.9/8.14.5) with ESMTP id t1D9vbu3021802
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=FAIL)
	for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 01:57:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all

I made this test on ubuntu 14.04 with kernel 3,19-rc7:

1. brctl addbr br0

2. ifconfig br0 up

3. ifconfig br0 (br0's status is with 'RUNNING')

4. brctl addif br0 eth0

5. brctl delif br0 eth0

6. ifconfig br0 (br0's status is without 'RUNNING')

When there is no sub-interface, the flag "RUNNING" is missing after the 
last sub-interface is removed.

As such, should we keep "RUNNING" flag after the last sub-interface is 
removed?

Thanks a lot.
Zhu Yanjun

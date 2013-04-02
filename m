From: "Peter Huang(Peng)" <peter.huangpeng@huawei.com>
Subject: intel 82580 nic hang problem.
Date: Tue, 2 Apr 2013 21:56:21 +0800
Message-ID: <515AE385.7040006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Majun <harry.majun@huawei.com>, <netdev@vger.kernel.org>,
	Zhoukang <zhoukang7@huawei.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:31808 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760162Ab3DBN4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 09:56:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric

Here I have a nic hang problem in our customer environment, from Intel's 82575
driver release notes, there was a similar problem, but only occurred with older
linux 2.6 kernel ( we are using 3.0.13-0.27-xen kernel).

We are using 82580 dual port NIC:
#ethtool -i eth1

driver: igb
version: 3.0.6-k2
firmware-version: 3.2-9
bus-info: 0000:02:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes

Below is the error message (this msg will repeated over 8 hours):
Mar 28 10:46:25 CNA001_0_010203 kernel: [ 4412.812078] igb 0000:02:00.1: eth1: Reset adapter
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816189] igb 0000:02:00.1: Detected Tx Unit Hang
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816191]   Tx Queue             <1>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816191]   TDH                  <0>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816192]   TDT                  <2>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816192]   next_to_use          <2>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816193]   next_to_clean        <0>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816193] buffer_info[next_to_clean]
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816194]   time_stamp           <1000fb54c>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816194]   next_to_watch        <0>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816195]   jiffies              <1000fb649>
Mar 28 10:46:31 CNA001_0_010203 kernel: [ 4418.816196]   desc.status          <118000>

Are you familiar with this problem, or could you give us any suggestion to move on?

Thanks very much!

Peter.Huang

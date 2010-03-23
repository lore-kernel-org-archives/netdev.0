From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: 2.6.34-rc1 regression: rmmod hangs on modules which interfaces have
 ipv6 address
Date: Mon, 22 Mar 2010 18:02:52 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4A7FB39@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:20391 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755716Ab0CWACy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 20:02:54 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steps to reproduce:
1. Load driver
2. Bring interfaces up with IPv6 address 
3. rmmod the driver

rmmod fails with "waiting for device to become free. Usage count=1"

Bisecting turned up this patch:
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=3e81c6da39a265e11ef48f52bd15bf7ca0068c75

Although I can't confirm this since without it I am not able to assign IPv6 addresses. So it could be caused by whatever this commit is trying to fix.

Thanks,
Emil
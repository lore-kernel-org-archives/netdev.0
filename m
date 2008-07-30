From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: eth0 link off
Date: Wed, 30 Jul 2008 13:31:17 -0300
Message-ID: <48909755.3070205@linux.vnet.ibm.com>
References: <233373.95650.qm@web50111.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nitinm76@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw3.br.ibm.com ([32.104.18.26]:34341 "EHLO igw3.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751068AbYG3QcG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2008 12:32:06 -0400
Received: from mailhub1.br.ibm.com (unknown [9.18.232.109])
	by igw3.br.ibm.com (Postfix) with ESMTP id 829B23902D0
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 13:13:11 -0300 (BRST)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6UGW4Os1782204
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 13:32:09 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6UGVwtD004308
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2008 13:31:58 -0300
In-Reply-To: <233373.95650.qm@web50111.mail.re2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nitin Mahajan wrote:

> I have configured a Ethernet driver in linux-2.6.24.2 kernel version.
> The interface comes up and I can see the 'eth0' interface when i do
> 'ifconfig -a'.
Is the interface up?  Discover using 'ifconfig ethX | grep UP'

> However when I try to configure the network interface it always says
> 'eth0 link off'. Can some one please point me to the problem and tell
> me at what stage this message is coming from?
What does "configure" mean in this context ? What is the result of
'ethtool -t ethX' ?

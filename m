From: Rick Jones <rick.jones2@hp.com>
Subject: wither bounds checking for networking sysctls
Date: Thu, 30 Aug 2007 18:09:17 -0700
Message-ID: <46D76A3D.9090207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:59577 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbXHaBJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 21:09:39 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id 9A16B39391
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 18:09:28 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id SAA04473
	for <netdev@vger.kernel.org>; Thu, 30 Aug 2007 18:09:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While messing about with "sysctl_tcp_rto_min" I went back and forth a 
bit as to whether there should have been bounds checking (as did some of 
the folks who did some internal review for me).  That leads to the 
question - is it considered worthwhile to add a bit more bounds checking 
to sundry networking sysctls?

rick jones

From: Sachin Sant <sachinp@in.ibm.com>
Subject: [-next Oct 13] Build failure drivers/s390/net/ctcm_mpc.o
Date: Wed, 13 Oct 2010 20:39:16 +0530
Message-ID: <4CB5CB9C.9030603@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	linux-s390@vger.kernel.org, ursula.braun@de.ibm.com,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:43316 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751199Ab0JMPJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 11:09:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today's next fails to build on a s390 box with following
error

drivers/s390/net/ctcm_mpc.c: In function ctc_mpc_dealloc_ch:
drivers/s390/net/ctcm_mpc.c:541: error: struct net_device has no member named refcnt

The code in question was changed by
commit 29b4433d991c88d86ca48a4c1cc33c671475be4b
net: percpu net_device refcount

The net_device struct member refcnt was changed from atomic_t to
int __percpu.

Thanks
-Sachin


-- 

---------------------------------
Sachin Sant
IBM Linux Technology Center
India Systems and Technology Labs
Bangalore, India
---------------------------------


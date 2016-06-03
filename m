From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: latest net-next does not build on sparc?
Date: Fri, 3 Jun 2016 18:39:25 -0400
Message-ID: <20160603223925.GQ16616@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39285 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814AbcFCWj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 18:39:29 -0400
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id u53MdRkY011251
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 22:39:28 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.13.8/8.13.8) with ESMTP id u53MdR1E030170
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 22:39:27 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id u53MdR4v016210
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2016 22:39:27 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just pulled 4.7.0-rc1, and I find a build error

kernel/locking/rwsem.c: In function ?down_write_killable?:
kernel/locking/rwsem.c:65: error: implicit declaration of function ?__down_write_killable?
make[2]: *** [kernel/locking/rwsem.o] Error 1

I had to pull in this patch:
  http://lkml.iu.edu/hypermail/linux/kernel/1602.3/04431.html
to get it  to build- did I just miss something in my pull?

--Sowmini

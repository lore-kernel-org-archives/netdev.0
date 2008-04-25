From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PULL] [IPV6] COMPAT: Fix SSM applications on 64bit
 kernels.
Date: Fri, 25 Apr 2008 15:37:33 +0900 (JST)
Message-ID: <20080425.153733.98184095.yoshfuji@linux-ipv6.org>
References: <20080424.170257.87949659.yoshfuji@linux-ipv6.org>
	<OF3A37018B.9EFE360C-ON88257435.00614684-88257435.00622448@us.ibm.com>
	<20080424.233159.06679047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33523 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883AbYDYGhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:37:34 -0400
In-Reply-To: <20080424.233159.06679047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <20080424.233159.06679047.davem@davemloft.net> (at Thu, 24 Apr 2008 23:31:59 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> 1) Use copy_in_user() as that's the proper interaface to copy within
>    userspace in COMPAT code.

So, don't we care increase of copy operation with it?

--yoshfuji

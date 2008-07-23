From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: Re: someone broke qeth_l3_main.c
Date: Wed, 23 Jul 2008 10:37:10 +0200
Message-ID: <1216802230.5517.13.camel@localhost>
References: <20080723012805.8a528347.akpm@linux-foundation.org>
Reply-To: schwidefsky@de.ibm.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:25794 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbYGWIhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 04:37:14 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id m6N8bCiL031474
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 08:37:12 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6N8bBdV4112620
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 10:37:11 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6N8bBTA021863
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 10:37:11 +0200
In-Reply-To: <20080723012805.8a528347.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-23 at 01:28 -0700, Andrew Morton wrote:
> drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_hard_start_xmit':
> drivers/s390/net/qeth_l3_main.c:2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
> drivers/s390/net/qeth_l3_main.c:2654: error: invalid type argument of '->'

Frank already sent a patch to Jeff to fix this. It should be in Jeffs
queue now.

-- 
blue skies,
  Martin.

"Reality continues to ruin my life." - Calvin.



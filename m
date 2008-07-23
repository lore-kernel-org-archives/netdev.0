From: Andrew Morton <akpm@linux-foundation.org>
Subject: someone broke qeth_l3_main.c
Date: Wed, 23 Jul 2008 01:28:05 -0700
Message-ID: <20080723012805.8a528347.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54965 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750873AbYGWIaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 04:30:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_hard_start_xmit':
drivers/s390/net/qeth_l3_main.c:2654: error: implicit declaration of function 'VLAN_TX_SKB_CB'
drivers/s390/net/qeth_l3_main.c:2654: error: invalid type argument of '->'

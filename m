From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/2] [AF_IUCV] fixes for net-2.6.24
Date: Sun, 07 Oct 2007 23:20:52 -0700 (PDT)
Message-ID: <20071007.232052.30160732.davem@davemloft.net>
References: <20071004144608.880229000@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	heiko.carstens@de.ibm.com
To: braunu@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51736
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751694AbXJHGUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 02:20:53 -0400
In-Reply-To: <20071004144608.880229000@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>
Date: Thu, 04 Oct 2007 16:46:08 +0200

> the following 2 patches are intended for 2.6.24 and contain:
> - removal of static declarations in af_iucv header file
> - postpone receival of inbound packets in af_iucv

These patches don't apply, for one thing the first patch
rejects because the net-2.6.24 copy of include/net/iucv/af_iucv.h
has this line:

+static int  iucv_sock_create(struct socket *sock, int proto);

but the file you are patching against does not.

Please generate new clean patches against net-2.6.24, thank you.

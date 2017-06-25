From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] af_iucv: Move sockaddr length checks to
 before accessing sa_family in bind and connect handlers
Date: Sun, 25 Jun 2017 11:43:18 -0400 (EDT)
Message-ID: <20170625.114318.948212702920832807.davem@davemloft.net>
References: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
        <20170623173228.70128-3-jwi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: jwi@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40386 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdFYPnU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 11:43:20 -0400
In-Reply-To: <20170623173228.70128-3-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Date: Fri, 23 Jun 2017 19:32:28 +0200

> From: Mateusz Jurczyk <mjurczyk@google.com>
> 
> Verify that the caller-provided sockaddr structure is large enough to
> contain the sa_family field, before accessing it in bind() and connect()
> handlers of the AF_IUCV socket. Since neither syscall enforces a minimum
> size of the corresponding memory region, very short sockaddrs (zero or
> one byte long) result in operating on uninitialized memory while
> referencing .sa_family.
> 
> Fixes: 52a82e23b9f2 ("af_iucv: Validate socket address length in iucv_sock_bind()")
> Signed-off-by: Mateusz Jurczyk <mjurczyk@google.com>
> [jwi: removed unneeded null-check for addr]
> Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Applied.

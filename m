From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: active-backup/bonding with drivers not supporting set_mac_address()
Date: Mon, 10 Jul 2006 11:31:48 -0700
Message-ID: <200607101831.k6AIVmp0026998@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0607101618390.26558@zuben> <20060710.112322.100334803.davem@davemloft.net>
Cc: ogerlitz@voltaire.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:7840 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S965203AbWGJSbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 14:31:50 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6AIVn8t026968
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 14:31:50 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6AIVn9Y280266
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 14:31:49 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6AIVnZC010092
	for <netdev@vger.kernel.org>; Mon, 10 Jul 2006 14:31:49 -0400
To: David Miller <davem@davemloft.net>
In-reply-to: <20060710.112322.100334803.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
[...]
>Regardless of whether we add support for active-backup/bonding for
>devices without this method, in the mean time the bonding
>driver should check for whether that method is NULL and disallow
>the bond configuration if it is.

	That's what it does; if a slave lacks a set_mac_address
function, the enslavement fails.  Changes to the MAC are done via
dev_set_mac_address.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH RESEND net-next 1/7] bonding: use ether_addr_equal_unaligned
 for bond addr compare
Date: Thu, 2 Jan 2014 16:21:20 +0800
Message-ID: <52C52180.2030707@huawei.com>
References: <52C4BD16.5010702@huawei.com> <alpine.DEB.2.02.1401020839000.2182@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:31594 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800AbaABIWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 03:22:13 -0500
In-Reply-To: <alpine.DEB.2.02.1401020839000.2182@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/2 15:39, Julia Lawall wrote:
> Are the casts needed


Yes, otherwise the warming will report:

/net-next/drivers/net/bonding/bond_3ad.c:427: warning: passing argument=
 1 of =E2=80=98ether_addr_equal_64bits=E2=80=99 from incompatible point=
er type

Regards
Ding

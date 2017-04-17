From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ncsi: fix checksum validation in response packet
Date: Mon, 17 Apr 2017 13:36:19 -0400 (EDT)
Message-ID: <20170417.133619.1515025171498720534.davem@davemloft.net>
References: <1492160197-13816-1-git-send-email-clg@kaod.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: gwshan@linux.vnet.ibm.com, joel@jms.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: clg@kaod.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492160197-13816-1-git-send-email-clg@kaod.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cédric Le Goater <clg@kaod.org>
Date: Fri, 14 Apr 2017 10:56:37 +0200

> htonl was used instead of ntohl. Surely a typo.
> 
> Signed-off-by: Cédric Le Goater <clg@kaod.org>

I don't think so, "checksum" is of type "u32" thus is in host byte
order.  Therefore "htonl()" is correct.

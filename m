From: Brice Goglin <brice@myri.com>
Subject: [PATCH 0/5] myri10ge updates for 2.6.24
Date: Sat, 13 Oct 2007 12:31:38 +0200
Message-ID: <47109E8A.8080205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2002 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753406AbXJMKdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 06:33:36 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Now that LRO and the new NAPI have landed in myri10ge for 2.6.24, here's
a couple updates. The big part is support for IPv6 TSO, which requires
the addition of skb_is_gso_v6(). I am CC'ing Dave and Herbert in the
corresponding mails. The other patches are trivial.

1. myri10ge: fix some indentation, white spaces, and comments
2. myri10ge: update firmware headers
3. [IPV6]: add skb_is_gso_v6()
4. myri10ge: add IPv6 TSO support
5. myri10ge: update driver version to 1.3.2-1.287

Please apply for 2.6.24.

Thanks,
Brice


From: jamal <hadi@cyberus.ca>
Subject: [PATCH 0/2] [IPSEC]: Reinject packet instead of calling netfilter
	directly on input
Date: Thu, 29 Nov 2007 15:49:34 -0500
Message-ID: <1196369374.4437.18.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:35326 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761582AbXK2Utk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 15:49:40 -0500
Received: by py-out-1112.google.com with SMTP id u77so3845315pyb
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2007 12:49:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

This is a simplified version of one of your earlier patches that never
made it in. I liked it so much that i reduced it to this and infact
given the cycles today, tested it (with transport and tunnel mode
only;->).

We re-inject a decrypted ipsec (other than tunnel mode) back and let it
bubble up the network stack. This improves debugability (since sniffers
like tcpdump can see the packet) and usability since ingress tc filters
can act on it.

Ive broken it down into two: IPv4 and IPV6. If you want to go through
the xfrm reinject() method, then I am gonna need more time to resubmit
or you be my guest and go for it and i will test it.

cheers,
jamal




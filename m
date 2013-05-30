From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Patch net-next v3] net: clean up skb headers code
Date: Thu, 30 May 2013 12:18:13 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7258@saturn3.aculab.com>
References: <1369879575-18701-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Simon Horman" <horms@verge.net.au>
To: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49295 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S968083Ab3E3LW0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 07:22:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 02951-09 for <netdev@vger.kernel.org>;
 Thu, 30 May 2013 12:22:17 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1369879575-18701-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> commit 1a37e412a0225fcba5587 (net: Use 16bits for *_headers
> fields of struct skbuff) converts skb->*_header to u16,
> some #if NET_SKBUFF_DATA_USES_OFFSET are now useless,
> and to be safe, we could just use "X = ~(typeof(X))0;"
> as suggested by David and Ben.

IIRC ~(unsigned short)0 is the same as ~0 and will be -1.
define an actual constant with value 0xffff

	David

From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4]: Uninline netfilter okfns
Date: Mon, 15 Oct 2007 01:49:01 -0700 (PDT)
Message-ID: <20071015.014901.129468456.davem@davemloft.net>
References: <46FFC2F4.8090602@trash.net>
	<20071014042604.GA11431@gondor.apana.org.au>
	<47131D64.3080008@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37859
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756193AbXJOIs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:48:57 -0400
In-Reply-To: <47131D64.3080008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 15 Oct 2007 09:57:24 +0200

> Your patches work fine so far, tested with fragments, packet
> content mangling etc. Thanks again for doing this. And they
> really do enable gcc to generate tail-calls for the NF_HOOK
> okfns, so this patch changes net/ipv4 to take advantage of
> this. IPv6 and bridge will follow ...

Applied, thanks Patrick!

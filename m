From: David Miller <davem@davemloft.net>
Subject: Re: DF, IP ID always 0 and the reassembly protections
Date: Tue, 20 Jun 2006 17:43:00 -0700 (PDT)
Message-ID: <20060620.174300.95506284.davem@davemloft.net>
References: <44988877.2030205@hp.com>
	<20060620.171912.70221261.davem@davemloft.net>
	<44989466.5070308@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:23706
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751878AbWFUAmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 20:42:50 -0400
To: rick.jones2@hp.com
In-Reply-To: <44989466.5070308@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 20 Jun 2006 17:35:50 -0700

> I thought the ID's even in non-fragmented datagrams gave an idea of how 
> many IP datagrams had been sent along, and so an idea of how "unlikely" 
> it was that a datagram with holes could be reassembled?

The code you are thinking about is in net/ipv4/ip_fragment.c and it
attempts to avoid ID wrapping corruption.  It only looks at IP
fragments on input.

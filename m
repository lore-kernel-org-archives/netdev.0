From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH] net: fix checking boundary of valid vlan id
Date: Mon, 31 Dec 2012 18:12:58 +0100
Message-ID: <m3fw2mp2lh.fsf@ursa.amorsen.dk>
References: <1356848931-22193-1-git-send-email-akong@redhat.com>
	<20121230122542.GC11727@breakpoint.cc>
	<186CBD58-5106-4FCD-8C73-E4EC84C3A303@gdt.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, akong@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Glen Turner <gdt@gdt.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.ipvision.dk ([94.127.49.3]:41673 "EHLO gate2.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751187Ab2LaRXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 12:23:53 -0500
In-Reply-To: <186CBD58-5106-4FCD-8C73-E4EC84C3A303@gdt.id.au> (Glen Turner's
	message of "Mon, 31 Dec 2012 22:06:43 +1030")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Glen Turner <gdt@gdt.id.au> writes:

> It may be a valid VLAN ID, or it may not. The meaning of FFF is
> reserved for vendor use, which doesn't preclude a vendor using it as a
> (non-interoperable) VLAN identifier. Many vendor's products treat 4096
> as they do any other VID.

I may be missing something vital, but 4096 is 0x1000 not 0xFFF? 4095 is
reserved and 0 means "treat as if the packet was untagged". 4096 is
impossible, there are only 12 bit and the encoding is AFAIK bog standard
binary.


/Benny

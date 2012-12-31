From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH] net: fix checking boundary of valid vlan id
Date: Tue, 1 Jan 2013 09:00:14 +1030
Message-ID: <4DDEA5B5-B887-44C7-8932-3CC3383E6896@gdt.id.au>
References: <1356848931-22193-1-git-send-email-akong@redhat.com> <20121230122542.GC11727@breakpoint.cc> <186CBD58-5106-4FCD-8C73-E4EC84C3A303@gdt.id.au> <m3fw2mp2lh.fsf@ursa.amorsen.dk>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Florian Westphal <fw@strlen.de>, akong@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:45989 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751901Ab2LaWbV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2012 17:31:21 -0500
In-Reply-To: <m3fw2mp2lh.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 01/01/2013, at 3:42 AM, Benny Amorsen wrote:

> Glen Turner <gdt@gdt.id.au> writes:
> 
>> It may be a valid VLAN ID, or it may not. The meaning of FFF is
>> reserved for vendor use, which doesn't preclude a vendor using it as a
>> (non-interoperable) VLAN identifier. Many vendor's products treat 4096
>> as they do any other VID.
> 
> I may be missing something vital, but 4096 is 0x1000 not 0xFFF? 4095 is
> reserved and 0 means "treat as if the packet was untagged". 4096 is
> impossible, there are only 12 bit and the encoding is AFAIK bog standard
> binary.

Yep, I've failed at hex math. 0xfff = 4095 is the maximal VID value, and is the one reserved for vendor use.
Which means that the patch checking values 1 to 4095 is correct.

My apologies,
glen
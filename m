From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Question about potential problem in net/ipv4/route.c
Date: Wed, 11 Oct 2006 22:54:24 -0700 (PDT)
Message-ID: <20061011.225424.49852465.davem@davemloft.net>
References: <200610111511.19028.dada1@cosmosbay.com>
	<20061011.220506.76273501.davem@davemloft.net>
	<452DD320.7060408@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5513
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161409AbWJLFyd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 01:54:33 -0400
To: kaber@trash.net
In-Reply-To: <452DD320.7060408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 12 Oct 2006 07:31:12 +0200

> This program demonstrates the effect, it doesn't output the expected
> "1 2" but "1 4294967042" on my x86_64 (gcc-Version 4.1.2 20060901
> (prerelease) (Debian 4.1.1-13)). The initialization doesn't touch
> the padding bytes:
> 
> 0x0000000000400494 <test+8>:    movl   $0x1,0xfffffffffffffff0(%rbp)
> 0x000000000040049b <test+15>:   movb   $0x2,0xfffffffffffffff4(%rbp)

Crap, ok we need to fix this.

I even looked at the assembler for a little test foo.c bit
of code... must have misread the sparc64 asm :)

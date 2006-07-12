From: David Miller <davem@davemloft.net>
Subject: Re: [NETROM] lockdep: fix false positive
Date: Wed, 12 Jul 2006 13:26:33 -0700 (PDT)
Message-ID: <20060712.132633.34391834.davem@davemloft.net>
References: <20060711221142.GA5721@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21651
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751046AbWGLUZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:25:44 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060711221142.GA5721@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 11 Jul 2006 23:11:42 +0100

> NETROM network devices are virtual network devices encapsulating NETROM
> frames into AX.25 which will be sent through an AX.25 device, so form a
> special "super class" of normal net devices; split their locks off into a
> separate class since they always nest.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks.

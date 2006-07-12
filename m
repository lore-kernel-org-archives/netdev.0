From: David Miller <davem@davemloft.net>
Subject: Re: [ROSE] lockdep: fix false positive
Date: Wed, 12 Jul 2006 13:26:06 -0700 (PDT)
Message-ID: <20060712.132606.111694378.davem@davemloft.net>
References: <20060711221357.GA5813@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:20371
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751013AbWGLUZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 16:25:17 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060711221357.GA5813@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Tue, 11 Jul 2006 23:13:57 +0100

> ROSE network devices are virtual network devices encapsulating ROSE
> frames into AX.25 which will be sent through an AX.25 device, so form a
> special "super class" of normal net devices; split their locks off into
> a separate class since they always nest.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks.

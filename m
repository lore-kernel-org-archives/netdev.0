From: David Miller <davem@davemloft.net>
Subject: Re: Off by one buglets
Date: Mon, 03 Jul 2006 19:34:15 -0700 (PDT)
Message-ID: <20060703.193415.48529803.davem@davemloft.net>
References: <20060630142901.GA13898@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15036
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750875AbWGDCd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 22:33:59 -0400
To: ralf@linux-mips.org
In-Reply-To: <20060630142901.GA13898@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 30 Jun 2006 15:29:01 +0100

> Ages ago, changeset
> 
> http://www.kernel.org/git/?p=linux/kernel/git/tglx/history.git;a=commit;h=22d864d542a0b92116751186f1794c7d0f1ca1b9
> 
> which converted several protocols from using open coded comparisons to
> use the helper function sk_acceptq_is_full() did introduce a bunch of
> off by one errors - sk_acceptq_is_full checks for
> sk_ack_backlog > sk_max_ack_backlog but it replaced >= or == comparisons.
> 
> Below patch is really only meant to illustrate the change, not to be
> applied.

Ok, I'll try to resolve this when I get back from my vacation
unless someone beats me to it.

Thanks for the heads up Ralf.

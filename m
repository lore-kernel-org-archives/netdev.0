From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] asmlinkage, wan/sbni: Make inline assembler
 symbols visible and assembler global
Date: Tue, 22 Oct 2013 13:59:28 -0400 (EDT)
Message-ID: <20131022.135928.2040131908206663695.davem@davemloft.net>
References: <1382458346-24811-1-git-send-email-andi@firstfloor.org>
	<1382458346-24811-12-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	ak@linux.intel.com, netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382458346-24811-12-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 22 Oct 2013 09:12:26 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> - Inline assembler defining C callable code has to be global
> - The function has to be visible
> 
> Do this in wan/sbni
> 
> Cc: netdev@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Is it really impossible to use the generic crc32 support instead of this
unsightly custom inline assembler?

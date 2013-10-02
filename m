From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] tcp: Always set options to 0 before calling
 tcp_established_options
Date: Wed, 02 Oct 2013 16:33:26 -0400 (EDT)
Message-ID: <20131002.163326.2302966214580101265.davem@davemloft.net>
References: <1380572952-30729-1-git-send-email-andi@firstfloor.org>
	<1380572952-30729-11-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ak@linux.intel.com,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380572952-30729-11-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Mon, 30 Sep 2013 13:29:11 -0700

> From: Andi Kleen <ak@linux.intel.com>
> 
> tcp_established_options assumes opts->options is 0 before calling,
> as it read modify writes it.
> 
> For the tcp_current_mss() case the opts structure is not zeroed,
> so this can be done with uninitialized values.
> 
> This is ok, because ->options is not read in this path.
> But it's still better to avoid the operation on the uninitialized
> field. This shuts up a static code analyzer, and presumably
> may help the optimizer.
> 
> Cc: netdev@vger.kernel.org
> Signed-off-by: Andi Kleen <ak@linux.intel.com>

Applied.

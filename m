From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next/master] ethernet/broadcom/tg3: Fix sparse
 warning: constant 0x7fffffffffffffff is so big it is long long
Date: Fri, 04 Jan 2013 15:11:46 -0800 (PST)
Message-ID: <20130104.151146.1432785010798255784.davem@davemloft.net>
References: <50beaf6a.HF5L0P4z6BqrUx/x%fengguang.wu@intel.com>
	<1357223030-29155-1-git-send-email-peterhuewe@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mcarlson@broadcom.com, nsujir@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	fengguang.wu@intel.com, kbuild@01.org
To: peterhuewe@gmx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357223030-29155-1-git-send-email-peterhuewe@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter Huewe <peterhuewe@gmx.de>
Date: Thu,  3 Jan 2013 15:23:50 +0100

> Sparse complains that:
> drivers/net/ethernet/broadcom/tg3.c:5670:55: sparse: constant
> 0x7fffffffffffffff is so big it is long long (on x86/32 bit)
> 
> so we suffix the constant with LL in the header file.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Peter Huewe <peterhuewe@gmx.de>

Applied.

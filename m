From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH 2/2] net: macb: Handle errors in RX path
Date: Fri, 18 Jul 2014 15:35:22 +0530
Message-ID: <53C8F162.9020304@gmail.com>
References: <53C8EE99.6070605@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Neil Armstrong <superna9999@gmail.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53C8EE99.6070605@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/18/2014 03:23 PM, Neil Armstrong wrote:
> In certain circumstances, the MACB fails to write correct RX ring
> descriptor, and lead to actually managed by BUG_ON() error cases.
>
> Handle these two cases by returning error values, while resetting
> the RX ring and RX HW path in the poll methos.
>
> In the same time, check and handle BNA and OVR into poll method
> by using the same error management.
>
> Signed-off-by: Neil Armstrong <narmstrong@neotion.com>
> ---
>   drivers/net/ethernet/cadence/macb.c |   55 +++++++++++++++++++++++++++++++---
>   1 files changed, 50 insertions(+), 5 deletions(-)
>
checkpatch errors/warnings on this patch...

-- 
Regards,
Varka Bhadram.

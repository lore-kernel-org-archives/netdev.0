From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH] cxgbi: bug fixes and code cleanup
Date: Wed, 22 Sep 2010 15:09:33 -0500
Message-ID: <4C9A627D.4060800@cs.wisc.edu>
References: <201009211609.o8LG9HPm014568@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com, rranjan@chelsio.com,
	James.Bottomley@HansenPartnership.com, davem@davemloft.net
To: kxie@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <201009211609.o8LG9HPm014568@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/21/2010 11:09 AM, kxie@chelsio.com wrote:
> [PATCH] cxgbi: bug fixes and code cleanup
>
> From: Karen Xie<kxie@chelsio.com>
>
> The patch includes the following changes.
> - removed un-used code
> - renamed alloc_cpl() to alloc_wr().
> - fixed connecting over VLAN.
> - updated cxgb4i connection setting and pagepod programming.

Could you break up the patch into a patch per change next time?


> -				read_lock(&csk->callback_lock);
>   				dskb = skb_peek(&csk->receive_queue);
>   				if (!dskb) {
>   					read_unlock(&csk->callback_lock);

I think you also have to remove this read_unlock call.

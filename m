From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH 2/3] tg3: Fix tx_pending checks for tg3_tso_bug
Date: Tue, 19 Aug 2014 13:56:27 -0700
Message-ID: <20140819205627.GA20702@f1.synalogic.ca>
References: <1408474371-19509-1-git-send-email-bpoirier@suse.de>
 <1408474371-19509-2-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1408474371-19509-2-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014/08/19 11:52, Benjamin Poirier wrote:
> +		trace_printk("stopping queue, %d <= %d\n",
> +			     tg3_tx_avail(tnapi), skb_shinfo(skb)->gso_segs);
>  		netif_tx_stop_queue(txq);
> +		trace_printk("stopped queue\n");

err, I'll resubmit without the trace_printk. Please review for other
issues nevertheless.

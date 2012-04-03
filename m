From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 0/2] Ethernet drivers for WIZnet chips
Date: Tue, 03 Apr 2012 13:39:30 +0200
Message-ID: <1333453170.18626.65.camel@edumazet-glaptop>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
	 <1333450726-24455-1-git-send-email-msink@permonline.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Sinkovsky <msink@permonline.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1333450726-24455-1-git-send-email-msink@permonline.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-04-03 at 16:58 +0600, Mike Sinkovsky wrote:
> Based on original driver from chip manufacturer, but nearly full rewite.
> Tested and used in production with Blackfin BF531 embedded processor.
> 
> Signed-off-by: Mike Sinkovsky <msink@permonline.ru>
> ---
> v6:
>  - remove (S0_TX_FSR < skb->len) check in TX handler, it doesn't work
>    anyway. Chip can transmit only one frame with MTU 1500 at a time,
>    and tx buffer size is bigger.

So what happens if XXX frames are given to start_xmit() in a flood ?

You removed any flow control, how can this work ?

Device has an infinite queue ?

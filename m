From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net v5 0/4] r8152 bug fixes
Date: Mon, 23 Dec 2013 10:20:35 +0800
Message-ID: <7C579EF45BE74AFFB7218148FE7554F6@realtek.com.tw>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com> <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'nic_swsd' <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: 'Hayeswang' <hayeswang@realtek.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384939857-13519-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Any response? 

> -----Original Message-----
> From: Hayeswang [mailto:hayeswang@realtek.com] 
> Sent: Wednesday, November 20, 2013 5:31 PM
> To: netdev@vger.kernel.org
> Cc: nic_swsd; linux-kernel@vger.kernel.org; 
> linux-usb@vger.kernel.org; Hayeswang
> Subject: [PATCH net v5 0/4] r8152 bug fixes
> 
> For the patch #3, I add netif_tx_lock() before checking the
> netif_queue_stopped(). Besides, I add checking the skb queue
> length before waking the tx queue.
> 
> Hayes Wang (4):
>   r8152: fix tx/rx memory overflow
>   r8152: modify the tx flow
>   r8152: support stopping/waking tx queue
>   r8152: fix incorrect type in assignment
> 
>  drivers/net/usb/r8152.c | 114 
> +++++++++++++++++++++---------------------------
>  1 file changed, 50 insertions(+), 64 deletions(-)
> 
> -- 
> 1.8.3.1
> 
> 

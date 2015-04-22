From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [Patch net] igb: fix a typo in igb_reset_q_vector()
Date: Wed, 22 Apr 2015 09:26:11 +0900
Message-ID: <5536EAA3.10701@lab.ntt.co.jp>
References: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:49599 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbbDVA0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 20:26:23 -0400
In-Reply-To: <1429658433-8634-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/04/22 8:20, Cong Wang wrote:
> Fixes: 5536d2102a2d ("igb: Combine q_vector and ring allocation into a single function")
> Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 8457d03..85bbeb2 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -1036,7 +1036,7 @@ static void igb_reset_q_vector(struct igb_adapter *adapter, int v_idx)
>  		adapter->tx_ring[q_vector->tx.ring->queue_index] = NULL;
>  
>  	if (q_vector->rx.ring)
> -		adapter->tx_ring[q_vector->rx.ring->queue_index] = NULL;
> +		adapter->rx_ring[q_vector->rx.ring->queue_index] = NULL;
>  
>  	netif_napi_del(&q_vector->napi);
>  

Hi Cong Wang,

I have already sent a patch to intel's tree.
http://git.kernel.org/cgit/linux/kernel/git/jkirsher/net-queue.git/commit/?h=dev-queue&id=02ac4b65689f8df824117395fd8d160c04161a7b

Toshiaki Makita

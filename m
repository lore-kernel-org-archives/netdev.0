From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Patch 3/16 2.5] ixgb: Fix endianess issue for Tx cleanup
Date: Fri, 15 Oct 2004 13:04:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4170030A.4030508@pobox.com>
References: <Pine.LNX.4.44.0410150622460.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150622460.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:
> diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
> --- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
> +++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
> @@ -1677,7 +1677,7 @@ static boolean_t ixgb_clean_tx_irq(struc
>  	eop = tx_ring->buffer_info[i].next_to_watch;
>  	eop_desc = IXGB_TX_DESC(*tx_ring, eop);
>  
> -	while (eop_desc->status & cpu_to_le32(IXGB_TX_DESC_STATUS_DD)) {
> +	while(eop_desc->status & IXGB_TX_DESC_STATUS_DD) {
>  
>  		for (cleaned = FALSE; !cleaned;) {

patch OK but patch(1) could not apply the patch:


bk import -tpatch -CR -yixgb: Fix endianess issue for Tx cleanup 
/tmp/patch4377 .
Patching...
Patch failed.  **** patch log follows ****
Patching file drivers/net/ixgb/ixgb_main.c
1 out of 1 hunk FAILED -- saving rejects to file 
drivers/net/ixgb/ixgb_main.c.rej

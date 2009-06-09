From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 8/8] qlge: bugfix: Get rid of errant
	spin_unlock().
Date: Tue, 9 Jun 2009 09:25:59 -0700
Message-ID: <20090609162559.GA25391@linux-ox1b.qlogic.org>
References: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com> <1244561974-25662-8-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:6486 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959AbZFIQdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 12:33:43 -0400
Content-Disposition: inline
In-Reply-To: <1244561974-25662-8-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I messed up the file mode on this. I will repost it.

Regards,
Ron Mercer

On Tue, Jun 09, 2009 at 08:39:34AM -0700, Ron Mercer wrote:
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge_main.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>  mode change 100644 => 100755 drivers/net/qlge/qlge_main.c
> 
> diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
> old mode 100644
> new mode 100755
> index 5055f5b..024c734
> --- a/drivers/net/qlge/qlge_main.c
> +++ b/drivers/net/qlge/qlge_main.c
> @@ -3299,7 +3299,6 @@ static int ql_adapter_up(struct ql_adapter *qdev)
>  	err = ql_adapter_initialize(qdev);
>  	if (err) {
>  		QPRINTK(qdev, IFUP, INFO, "Unable to initialize adapter.\n");
> -		spin_unlock(&qdev->hw_lock);
>  		goto err_init;
>  	}
>  	set_bit(QL_ADAPTER_UP, &qdev->flags);
> -- 
> 1.6.0.2

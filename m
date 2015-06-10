From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 19/19] bna: use netdev_* and dev_* instead of
 printk and pr_*
Date: Wed, 10 Jun 2015 13:29:50 -0700
Message-ID: <1433968190.32331.32.camel@perches.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
	 <1433954605-22813-20-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@qlogic.com
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0216.hostedemail.com ([216.40.44.216]:33646 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932939AbbFJU3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 16:29:53 -0400
In-Reply-To: <1433954605-22813-20-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-10 at 18:43 +0200, Ivan Vecera wrote:
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

There should be some indication a few messages have
been deleted in the commit log and a reason why too.

> diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
[]
> @@ -965,10 +964,6 @@ bnad_cb_ethport_link_status(struct bnad *bnad,
>  						/*
>  						 * Force an immediate
>  						 * Transmit Schedule */
> -						printk(KERN_INFO "bna: %s %d "
> -						      "TXQ_STARTED\n",
> -						       bnad->netdev->name,
> -						       txq_id);

[]

> @@ -1057,8 +1051,6 @@ bnad_cb_tx_stall(struct bnad *bnad, struct bna_tx *tx)
>  		txq_id = tcb->id;
>  		clear_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
>  		netif_stop_subqueue(bnad->netdev, txq_id);
> -		printk(KERN_INFO "bna: %s %d TXQ_STOPPED\n",
> -			bnad->netdev->name, txq_id);

etc...

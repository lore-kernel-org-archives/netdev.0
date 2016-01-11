From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] iwl4965: Fix a null pointer dereference in
 il_tx_queue_free and il_cmd_queue_free
Date: Mon, 11 Jan 2016 13:12:08 +0100
Message-ID: <20160111121208.GD25015@redhat.com>
References: <1452167498-10823-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54662 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932103AbcAKMOE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 07:14:04 -0500
Content-Disposition: inline
In-Reply-To: <1452167498-10823-1-git-send-email-baijiaju1990@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 07, 2016 at 07:51:38PM +0800, Jia-Ju Bai wrote:
>  err:
> -	for (i = 0; i < actual_slots; i++)
> +	for (i = 0; i < actual_slots; i++) {
>  		kfree(txq->cmd[i]);
> +		txq->cmd[i] = NULL;

I don't think we need this, otherwise patch looks good.

Stanislaw

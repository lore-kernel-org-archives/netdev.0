From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/6] be2net: add be_cmd_set_port_speed_v1 to
 set port speed
Date: Sun, 07 Aug 2011 22:08:41 -0700 (PDT)
Message-ID: <20110807.220841.694439497105921625.davem@davemloft.net>
References: <20110805195958.GA13539@akhaparde-VBox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajit.khaparde@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48808 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab1HHFIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:08:46 -0400
In-Reply-To: <20110805195958.GA13539@akhaparde-VBox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajit.khaparde@Emulex.Com>
Date: Fri, 5 Aug 2011 14:59:58 -0500

> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index 8d178d2..863ae67 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -2367,3 +2367,38 @@ err:
>  	mutex_unlock(&adapter->mbox_lock);
 ...
> +	status = be_mcc_notify_wait(adapter);
> +err:
> +	spin_unlock_bh(&adapter->mcc_lock);
> +	return status;
> +}
> +

Please do not add trailing empty lines to source files, GIT complains
about this and will abort when I try to apply your patch.

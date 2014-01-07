From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/15] i40e: Expose AQ debugfs hooks
Date: Tue, 07 Jan 2014 15:34:58 -0500 (EST)
Message-ID: <20140107.153458.421617056579109012.davem@davemloft.net>
References: <1389087149-27962-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1389087149-27962-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, jesse.brandeburg@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44444 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707AbaAGUfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 15:35:00 -0500
In-Reply-To: <1389087149-27962-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  7 Jan 2014 01:32:15 -0800

> @@ -1523,6 +1523,116 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>  		} else {
>  			dev_info(&pf->pdev->dev, "clear_stats vsi [seid] or clear_stats pf\n");
>  		}
> +	} else if (strncmp(cmd_buf, "send aq_cmd", 11) == 0) {
> +		struct i40e_aq_desc *desc;
> +		i40e_status ret;
> +		desc = kzalloc(sizeof(struct i40e_aq_desc), GFP_KERNEL);
> +		if (!desc)
> +			goto command_write_done;

Please add an empty line between local variable declarations and code.

> +	} else if (strncmp(cmd_buf, "send indirect aq_cmd", 20) == 0) {
> +		struct i40e_aq_desc *desc;
> +		i40e_status ret;
> +		u16 buffer_len;
> +		u8 *buff;
> +		desc = kzalloc(sizeof(struct i40e_aq_desc), GFP_KERNEL);
> +		if (!desc)
> +			goto command_write_done;

Likewise.

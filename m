From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 11/15] i40e: debugfs command to change RSS queue count
Date: Thu, 12 Dec 2013 18:13:58 +0400
Message-ID: <52A9C4A6.9020409@cogentembedded.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com> <1386852051-27907-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:44436 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461Ab3LLON4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 09:13:56 -0500
Received: by mail-la0-f49.google.com with SMTP id er20so343867lab.22
        for <netdev@vger.kernel.org>; Thu, 12 Dec 2013 06:13:54 -0800 (PST)
In-Reply-To: <1386852051-27907-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12-12-2013 16:40, Jeff Kirsher wrote:

> From: Anjali Singhai Jain <anjali.singhai@intel.com>

> This is the 3rd of 3 patches that implements changing the number
> of queues on the fly.

> This patch adds the debugfs hook for calling the change queues
> flow with a request to change the number of RSS queues.

> This is intended to also be called eventually from ethtool.

> Change-Id: Ib6b332f0ec8e58989ef8c65ec30079d01fdf6c9a
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 12 ++++++++++++
>   1 file changed, 12 insertions(+)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> index 9c675b5..3303b43 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> @@ -1792,6 +1792,17 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
>   		}
>   		kfree(buff);
>   		buff = NULL;
> +	} else if (strncmp(cmd_buf, "set rss_size", 12) == 0) {
> +		u16 queue_count;

    Please insert empty line after declaration.

> +		cnt = sscanf(&cmd_buf[12], "%hi", &queue_count);

WBR, Sergei

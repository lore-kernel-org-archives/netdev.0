From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 03/15] i40evf: Remove some scary log messages
Date: Tue, 13 Jan 2015 17:22:29 +0300
Message-ID: <54B52A25.1040402@cogentembedded.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com> <1421148811-9763-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:49375 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788AbbAMOWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 09:22:33 -0500
Received: by mail-la0-f49.google.com with SMTP id hs14so2833408lab.8
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 06:22:32 -0800 (PST)
In-Reply-To: <1421148811-9763-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 1/13/2015 2:33 PM, Jeff Kirsher wrote:

> From: Mitch A Williams <mitch.a.williams@intel.com>

> These messages may be triggered during normal init of the driver if the
> PF or FW take a long time to respond. There's nothing really wrong, so
> don't freak people out logging messages.

> If the communication channel really is dead, then we'll retry a few
> times and give up. This will log a different more scary message that
> should cause consternation. This allows the user to more easily detect a
> genuine failure.

> Change-ID: I6e2b758d4234a3a09c1015c82c8f2442a697cbdb
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
> Tested-by: Jim Young <james.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]

> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> index ee0db59..f8f1d26 100644
> --- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> +++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
> @@ -2026,10 +2026,7 @@ static void i40evf_init_task(struct work_struct *work)
>   		/* aq msg sent, awaiting reply */
>   		err = i40evf_verify_api_ver(adapter);
>   		if (err) {
> -			dev_info(&pdev->dev, "Unable to verify API version (%d), retrying\n",
> -				 err);
>   			if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
> -				dev_info(&pdev->dev, "Resending request\n");
>   				err = i40evf_send_api_ver(adapter);
>   			}

    {} not needed anymore, should have removed them.

[...]

WBR, Sergei

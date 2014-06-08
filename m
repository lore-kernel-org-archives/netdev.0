From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 04/15] i40evf: remove unnecessary log messages
Date: Sun, 08 Jun 2014 10:23:42 -0700
Message-ID: <1402248222.6328.8.camel@joe-AO725>
References: <1402238037-20661-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1402238037-20661-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0182.hostedemail.com ([216.40.44.182]:37118 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753488AbaFHRXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jun 2014 13:23:46 -0400
In-Reply-To: <1402238037-20661-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-08 at 07:33 -0700, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>

A slightly associated trivial note:

One day it'd be nicer to use the same "if (!foo)"
test style everywhere.

> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
[]
> @@ -662,12 +661,9 @@ i40evf_vlan_filter *i40evf_add_vlan(struct i40evf_adapter *adapter, u16 vlan)
[]
>  		f = kzalloc(sizeof(*f), GFP_ATOMIC);
> -		if (NULL == f) {
> -			dev_info(&adapter->pdev->dev,
> -				 "%s: no memory for new VLAN filter\n",
> -				 __func__);
> +		if (NULL == f)
>  			return NULL;
> -		}
> +

[]

> @@ -1610,11 +1603,9 @@ static void i40evf_adminq_task(struct work_struct *work)
>  
>  	event.msg_size = I40EVF_MAX_AQ_BUF_SIZE;
>  	event.msg_buf = kzalloc(event.msg_size, GFP_KERNEL);
> -	if (!event.msg_buf) {
> -		dev_info(&adapter->pdev->dev, "%s: no memory for ARQ clean\n",
> -				 __func__);
> +	if (!event.msg_buf)
>  		return;
> -	}
> +

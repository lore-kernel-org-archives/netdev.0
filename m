From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 12/15] i40evf: make checkpatch happy
Date: Tue, 18 Nov 2014 20:59:45 -0800
Message-ID: <1416373185.6651.12.camel@perches.com>
References: <1416370256-16834-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416370256-16834-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0057.hostedemail.com ([216.40.44.57]:45117 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754829AbaKSE7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 23:59:49 -0500
In-Reply-To: <1416370256-16834-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-18 at 20:10 -0800, Jeff Kirsher wrote:
> This patch is the result of running checkpatch on the i40evf driver with
> the --strict option. The vast majority of changes are adding/removing
> blank lines, aligning function parameters, and correcting over-long
> lines.

Hey Mitch, Jeff:

> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
[]
> @@ -1265,8 +1269,8 @@ int i40evf_init_interrupt_scheme(struct i40evf_adapter *adapter)
>  	}
>  
>  	dev_info(&adapter->pdev->dev, "Multiqueue %s: Queue pair count = %u",
> -		(adapter->num_active_queues > 1) ? "Enabled" :
> -		"Disabled", adapter->num_active_queues);
> +		 (adapter->num_active_queues > 1) ? "Enabled" : "Disabled",
> +		 adapter->num_active_queues);

You could add a newline to that format one day.

> diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
[]
> @@ -711,7 +712,6 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
>  				"%s: Unknown event %d from pf\n",
>  				__func__, vpe->event);
>  			break;
> -
>  		}
>  		return;
>  	}
> @@ -776,7 +776,7 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
>  		break;
>  	default:
>  		dev_warn(&adapter->pdev->dev, "%s: Received unexpected message %d from PF\n",
> -			__func__, v_opcode);
> +			 __func__, v_opcode);
>  		break;
>  	} /* switch v_opcode */
>  	adapter->current_op = I40E_VIRTCHNL_OP_UNKNOWN;

And be consistent with PF vs pf usage too.

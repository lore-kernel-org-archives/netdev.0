From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 05/16] i40e: fix long lines
Date: Fri, 10 Jan 2014 01:07:49 -0800
Message-ID: <1389344869.24222.31.camel@joe-AO722>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344336-1558-6-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0127.hostedemail.com ([216.40.44.127]:40264 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751334AbaAJJHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 04:07:54 -0500
In-Reply-To: <1389344336-1558-6-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 00:58 -0800, Jeff Kirsher wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> Avoid over-length lines in order to appease checkpatch.

I think you can and should ignore long line warnings
where appropriate.

and...

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
[]
> @@ -681,7 +681,8 @@ aq_add_vsi_exit:
>   * @cmd_details: pointer to command details structure or NULL
>   **/
>  i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
> -				u16 seid, bool set, struct i40e_asq_cmd_details *cmd_details)
> +				u16 seid, bool set,
> +				struct i40e_asq_cmd_details *cmd_details)

Another way this could be changed is to put the
return value on a separate line like:

i40e_status
i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw, u16 seid, bool set,
				    struct i40e_asq_cmd_details *cmd_details)

> diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
[]
> @@ -93,9 +93,9 @@ i40e_status i40e_aq_set_vsi_broadcast(struct i40e_hw *hw,
>  				u16 vsi_id, bool set_filter,
>  				struct i40e_asq_cmd_details *cmd_details);
>  i40e_status i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw,
> -				u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);
> +		u16 vsi_id, bool set, struct i40e_asq_cmd_details *cmd_details);

i40e_status
i40e_aq_set_vsi_unicast_promiscuous(struct i40e_hw *hw, u16 vsi_id, bool set,
				    struct i40e_asq_cmd_details *cmd_details);

etc...

but once you use extremely long 35+ characters
function names, 80 columns gets a bit silly too.

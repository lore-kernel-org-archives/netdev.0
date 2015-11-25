From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 11/16] i40e/i40evf: clean up error messages
Date: Tue, 24 Nov 2015 16:49:26 -0800
Message-ID: <1448412566.20113.17.camel@perches.com>
References: <1448409886-90686-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448409886-90686-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0001.hostedemail.com ([216.40.44.1]:54211 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753794AbbKYAt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 19:49:29 -0500
In-Reply-To: <1448409886-90686-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-11-24 at 16:04 -0800, Jeff Kirsher wrote:
> Clean up and enhance error messages related to VF MAC/VLAN filters.
> Indicate which VF is having issues, and if possible indicate the MAC
> address or VLAN involved.

trivia:


> diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
[]
> @@ -1623,7 +1623,8 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
>  
>  		if (!f) {
>  			dev_err(&pf->pdev->dev,
> -				"Unable to add VF MAC filter\n");
> +				"Unable to add MAC filter %pM for VF %d\n",
> +				 al->list[i].addr, vf->vf_id);

Maybe use %hu for %d?
(here and elsewhere)

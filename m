From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1] ixgbe: add missing braces
Date: Fri, 10 Aug 2012 17:34:43 -0700
Message-ID: <1344645283.10630.5.camel@joe2Laptop>
References: <1344620114-6173-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Emil Tantilov <emil.s.tantilov@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59623 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751661Ab2HKAeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2012 20:34:44 -0400
In-Reply-To: <1344620114-6173-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 10:35 -0700, Peter P Waskiewicz Jr wrote:
> From: Emil Tantilov <emil.s.tantilov@intel.com>
[]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
[]
> @@ -804,12 +804,13 @@ static s32 ixgbe_setup_mac_link_82599(struct ixgbe_hw *hw,
>  	    link_mode == IXGBE_AUTOC_LMS_KX4_KX_KR_SGMII) {
>  		/* Set KX4/KX/KR support according to speed requested */
>  		autoc &= ~(IXGBE_AUTOC_KX4_KX_SUPP_MASK | IXGBE_AUTOC_KR_SUPP);
> -		if (speed & IXGBE_LINK_SPEED_10GB_FULL)
> +		if (speed & IXGBE_LINK_SPEED_10GB_FULL) {
>  			if (orig_autoc & IXGBE_AUTOC_KX4_SUPP)
>  				autoc |= IXGBE_AUTOC_KX4_SUPP;
>  			if ((orig_autoc & IXGBE_AUTOC_KR_SUPP) &&
>  			    (hw->phy.smart_speed_active == false))

trivial and unrelated:

Testing booleans against true|false is not good style.

"value == false" is better written as "!value", etc...

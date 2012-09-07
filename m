From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 0/12] qlcnic: patches for new adapter - Qlogic 83XX CNA
Date: Fri,  7 Sep 2012 19:01:21 -0400
Message-ID: <1347058893-30165-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:49188 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1757304Ab2IGXSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2012 19:18:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Re: [PATCH 11/12] qlcnic: 83xx adpater ethtool
>From: Ben Hutchings [mailto:bhutchings@solarflare.com]

>	#define QLCNIC_ETHTOOL_REGS_VER	2

> I think QLCNIC_ETHTOOL_REGS_VER needs to be changed,
> as you appear to be dumping more registers from the
> existing hardware as well.

> +static int qlcnic_set_channels(struct net_device *dev

> So you removed the body of qlcnic_set_channels() in an
> earlier patch, and now you're moving it and putting the body
> back how it was...  Please clean up the patch series
> so it doesn't have noise like this in it.

Re: [PATCH 10/12] qlcnic: register dump utility
> *dev,  static int qlcnic_set_channels(struct net_device *dev,
>  		struct ethtool_channels *channel)
>  {
> +	return 0;
>  }
[...]

> No, I don't think so. 
> If you're going to remove support for this operation
> then delete the function entirely.
> And don't put it in a patch that's supposed
> to do something unrelated.

Re: [PATCH 06/12] qlcnic: 83xx data path and HW interfaces routines
> +int qlcnic_83xx_set_settings(struct qlcnic_adapter *adapter,
> +			     struct ethtool_cmd *ecmd)
> +		return -EIO;

> Should be -EINVAL.

> +qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,

> +	default:
> +		dev_info(&adapter->pdev->dev, "Unknown get statistics mode\n");

> It seems like this default case can only be reached
> in case of a driver bug, so WARN would be more appropriate.


We have addressed all the issues raised by Ben Hutchings.
Please apply the updated 12 patch series to net-next.

Thanks,
Sony

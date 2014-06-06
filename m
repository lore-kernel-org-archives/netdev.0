From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next 2/2] net: use ethtool_cmd_speed_set helper to
 set ethtool speed value
Date: Fri, 6 Jun 2014 12:24:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17258956@AcuExch.aculab.com>
References: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
 <1402057021-12867-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>
To: 'Jiri Pirko' <jiri@resnulli.us>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41427 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751592AbaFFMZU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:25:20 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 21204-09 for <netdev@vger.kernel.org>;
 Fri,  6 Jun 2014 13:25:12 +0100 (BST)
In-Reply-To: <1402057021-12867-3-git-send-email-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko
...
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -141,6 +141,7 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
>  	struct e1000_dev_spec_82575 *dev_spec = &hw->dev_spec._82575;
>  	struct e1000_sfp_flags *eth_flags = &dev_spec->eth_flags;
>  	u32 status;
> +	u32 speed;
...
> +		speed = SPEED_UNKNOWN;

SPEED_UNKNOWN is defined as -1

	David

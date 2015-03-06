From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 2/3] bond: add support for
 ndo_switch_port_stp_update when bond is a bridge port
Date: Fri, 6 Mar 2015 07:55:42 +0100
Message-ID: <20150306065542.GB2004@nanopsycho.orion>
References: <1425614658-43701-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:33881 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917AbbCFGzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 01:55:47 -0500
Received: by wesx3 with SMTP id x3so4174296wes.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 22:55:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425614658-43701-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 06, 2015 at 05:04:17AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>This patch adds support for stp state offload netdev op to support the case
>where bond is a bridge port and bond slaves are switch ports.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Maybe the indent should be fixed for the rest to align with
.ndo_switch_port_stp_update. Not sure if that is needed thought. The
same note goes for team.

Acked-by: Jiri Pirko <jiri@resnulli.us>

>---
> drivers/net/bonding/bond_main.c |    1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 675b082..bf60535 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4005,6 +4005,7 @@ static const struct net_device_ops bond_netdev_ops = {
> 	.ndo_fix_features	= bond_fix_features,
> 	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
> 	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
>+	.ndo_switch_port_stp_update = ndo_dflt_netdev_switch_port_stp_update,
> };
> 
> static const struct device_type bond_type = {
>-- 
>1.7.10.4
>

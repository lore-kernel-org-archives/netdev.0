From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/3] switchdev: fix stp update API to work with
 layered netdevices
Date: Fri, 6 Mar 2015 07:53:46 +0100
Message-ID: <20150306065346.GA2004@nanopsycho.orion>
References: <1425614658-43701-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:36817 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751385AbbCFGxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 01:53:51 -0500
Received: by widem10 with SMTP id em10so1257737wid.1
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 22:53:49 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425614658-43701-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 06, 2015 at 05:04:16AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>make it same as the netdev_switch_port_bridge_setlink/dellink
>api (ie traverse lowerdevs to get to the switch port).
>
>removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because bridge ports
>can be bonds and teams which might not implement this ndo.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Looks good to me. Thanks for taking care of this.

Acked-by: Jiri Pirko <jiri@resnulli.us>

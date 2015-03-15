From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 1/3] switchdev: fix stp update API to work
 with layered netdevices
Date: Sun, 15 Mar 2015 17:57:41 +0100
Message-ID: <20150315165741.GG2043@nanopsycho.orion>
References: <1426206598-29410-2-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sfeldma@gmail.com, davem@davemloft.net, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:36865 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbCOQ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 12:57:44 -0400
Received: by wixw10 with SMTP id w10so24596232wix.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 09:57:43 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426206598-29410-2-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Mar 13, 2015 at 01:29:56AM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>make it same as the netdev_switch_port_bridge_setlink/dellink
>api (ie traverse lowerdevs to get to the switch port).
>
>removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because bridge ports
>can be bonds and teams which might not implement this ndo.
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>

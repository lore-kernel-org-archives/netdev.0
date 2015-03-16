From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v4] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 16 Mar 2015 18:36:59 +0100
Message-ID: <20150316173659.GJ2058@nanopsycho.orion>
References: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34148 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbbCPRhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:37:04 -0400
Received: by wegp1 with SMTP id p1so43659463weg.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 10:37:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426527159-8039-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 16, 2015 at 06:32:39PM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>make it same as the netdev_switch_port_bridge_setlink/dellink
>api (ie traverse lowerdevs to get to the switch port).
>
>removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
>direct bridge ports can be stacked netdevices (like bonds
>and team of switch ports) which may not imeplement this ndo.
>
>v2 to v3:
>	- remove changes to bond and team. Bring back the
>	transparently following lowerdevs like i initially
>	had for setlink/getlink
>	(http://www.spinics.net/lists/netdev/msg313436.html)
>	dave and scott feldman also seem to prefer it be that
>	way and move to non-transparent way of doing things
>	if we see a problem down the lane.
>
>v3 to v4:
>	- fix ret initialization
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>

Thanks Roopa!

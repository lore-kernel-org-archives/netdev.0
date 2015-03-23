From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v6] switchdev: fix stp update API to work with
 layered netdevices
Date: Mon, 23 Mar 2015 07:25:49 +0100
Message-ID: <20150323062549.GB2032@nanopsycho.orion>
References: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfeldma@gmail.com, netdev@vger.kernel.org
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:33784 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbbCWGZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 02:25:53 -0400
Received: by weop45 with SMTP id p45so129332668weo.0
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 23:25:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1426958848-2781-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 21, 2015 at 06:27:28PM CET, roopa@cumulusnetworks.com wrote:
>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>make it same as the netdev_switch_port_bridge_setlink/dellink
>api (ie traverse lowerdevs to get to the switch port).
>
>removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because
>direct bridge ports can be stacked netdevices (like bonds
>and team of switch ports) which may not implement this ndo.
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
>v4 to v5:
>	- return err on first failure (scott feldman)
>
>v5 to v6:
>	- change variable name (err) and initialize to
>	-EOPNOTSUPP (scott feldman).
>
>Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Acked-by: Jiri Pirko <jiri@resnulli.us>

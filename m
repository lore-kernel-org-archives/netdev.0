From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 07/18] switchdev: add new swdev bridge setlink
Date: Mon, 30 Mar 2015 14:31:28 +0200
Message-ID: <20150330123128.GH2045@nanopsycho.orion>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
 <1427704836-8776-8-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	linux@roeck-us.net, f.fainelli@gmail.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36011 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbbC3Mb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 08:31:57 -0400
Received: by wibg7 with SMTP id g7so101237129wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 05:31:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1427704836-8776-8-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 30, 2015 at 10:40:25AM CEST, sfeldma@gmail.com wrote:
>From: Scott Feldman <sfeldma@gmail.com>
>
>Add new swdev_port_bridge_setlink that can be used by drivers implementing
>.ndo_bridge_setlink to set swdev bridge attributes.  Basically turn the raw
>rtnl_bridge_setlink netlink into swdev attr sets.  Proper netlink attr policy
>checking is done.  Currently, only bridge port attrs BR_LEARNING and
>BR_LEARNING_SYNC are parsed and passed to port driver.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/net/switchdev.h   |    8 +++++
> net/switchdev/switchdev.c |   86 +++++++++++++++++++++++++++++++++++++++++++++
> 2 files changed, 94 insertions(+)
>

...

>+int swdev_port_bridge_setlink(struct net_device *dev,
>+			      struct nlmsghdr *nlh, u16 flags)
>+{
>+	struct nlattr *protinfo;
>+	struct nlattr *ifla;

	I would prefer just "attr" for example instead of "ifla"

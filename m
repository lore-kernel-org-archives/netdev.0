From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH iproute2 net-next-for-3.13 0/2] iproute2: display bonding
 slave info
Date: Mon, 10 Feb 2014 10:49:48 +0100
Message-ID: <20140210094948.GA2785@minipsycho.orion>
References: <20140210081136.66C22E5697@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:48944 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678AbaBJJv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 04:51:59 -0500
Received: by mail-ea0-f176.google.com with SMTP id h14so2843861eaj.35
        for <netdev@vger.kernel.org>; Mon, 10 Feb 2014 01:51:57 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140210081136.66C22E5697@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Already queued in patchwork:

http://patchwork.ozlabs.org/patch/313656/
http://patchwork.ozlabs.org/patch/313657/


Mon, Feb 10, 2014 at 09:11:36AM CET, mkubecek@suse.cz wrote:
>Since v3.14-rc1, kernel provides rtnetlink interface for read-only
>access to bonding slave parameters. Show this info in the output of
>"ip -d link show" command. The implementation is divided into generic
>part (add a callback to struct link_util and call it from
>print_linktype()) and bonding specific part (provide the callback in
>iplink_bond.c).
>
>Michal Kubecek (2):
>  iplink: display slave information
>  iplink_bond: add support for displaying bond slave attributes
>
> ip/ip_common.h   |  3 +++
> ip/ipaddress.c   | 27 +++++++++++++++++++++++--
> ip/iplink_bond.c | 61 ++++++++++++++++++++++++++++++++++++++++++++++++++++----
> 3 files changed, 85 insertions(+), 6 deletions(-)
>
>-- 
>1.8.1.4
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

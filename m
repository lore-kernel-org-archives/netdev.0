From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [patch net-next 0/5] bridge: implement rtnl_link options for
 getting and setting bridge options
Date: Fri, 5 Sep 2014 10:06:07 -0700
Message-ID: <20140905100607.51637cdd@urahara>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:49445 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaIERGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 13:06:11 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so22680748pab.15
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 10:06:11 -0700 (PDT)
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  5 Sep 2014 15:51:27 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> So far, only sysfs is complete interface for getting and setting bridge
> options. This patchset follows-up on the similar bonding code and
> allows userspace to get/set bridge master/port options using Netlink
> IFLA_INFO_DATA/IFLA_INFO_SLAVE_DATA attr.
> 
> Jiri Pirko (5):
>   bridge: switch order of rx_handler reg and upper dev link
>   bridge: implement rtnl_link_ops->get_slave_size and
>     rtnl_link_ops->fill_slave_info
>   bridge: implement rtnl_link_ops->slave_changelink
>   bridge: implement rtnl_link_ops->get_size and rtnl_link_ops->fill_info
>   bridge: implement rtnl_link_ops->changelink
> 
>  include/uapi/linux/if_link.h |  12 +++++
>  net/bridge/br_if.c           |  15 +++---
>  net/bridge/br_netlink.c      | 109 +++++++++++++++++++++++++++++++++++++++----
>  3 files changed, 121 insertions(+), 15 deletions(-)
> 

Looks good, I will try and go over in more detail and look for
any specific issues.

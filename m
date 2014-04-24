From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 1/2] rtnetlink: Warn when interface's information won't
 fit in our packet
Date: Thu, 24 Apr 2014 17:49:35 +0200
Message-ID: <20140424154935.GC2864@minipsycho.orion>
References: <1398298956-13084-1-git-send-email-david@gibson.dropbear.id.au>
 <1398298956-13084-2-git-send-email-david@gibson.dropbear.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ssujith@cisco.com, neepatel@cisco.com,
	benve@cisco.com, davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: David Gibson <david@gibson.dropbear.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:53810 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758450AbaDXPtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:49:39 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so1978117eei.5
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 08:49:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1398298956-13084-2-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 24, 2014 at 02:22:35AM CEST, david@gibson.dropbear.id.au wrote:
>Without IFLA_EXT_MASK specified, the information reported for a single
>interface in response to RTM_GETLINK is expected to fit within a netlink
>packet of NLMSG_GOODSIZE.
>
>If it doesn't, however, things will go badly wrong,  When listing all
>interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
>message in a packet as the end of the listing and omit information for
>that interface and all subsequent ones.  This can cause getifaddrs(3) to
>enter an infinite loop.
>
>This patch won't fix the problem, but it will WARN_ON() making it easier to
>track down what's going wrong.
>
>Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

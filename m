From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2] vxlan: change vxlan_[config_]validate() to
 use netlink_ext_ack for error reporting
Date: Fri, 11 Aug 2017 17:47:31 +0200
Message-ID: <20170811174731.51b71c65@griffin>
References: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <pshelar@ovn.org>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
        mschiffer@universe-factory.net, roopa@cumulusnetworks.com
To: Girish Moodalbail <girish.moodalbail@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45334 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752724AbdHKPrf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 11:47:35 -0400
In-Reply-To: <1502399795-25660-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Aug 2017 14:16:35 -0700, Girish Moodalbail wrote:
> +			NL_SET_ERR_MSG_ATTR(extack, tb[IFLA_VXLAN_PORT_RANGE],
> +					    "Provided source port range bounds is invalid");

s/bounds//?

> +	if (conf->label && !use_ipv6) {
> +		NL_SET_ERR_MSG(extack,
> +			       "Label attribute only applies for IPv6 VXLAN devices");

applies to

> +		if (!lowerdev) {
> +			NL_SET_ERR_MSG(extack,
> +				       "Specified interface for tunnel endpoint communications not found");

s/communications//?

> +		if (vxlan_addr_multicast(&conf->remote_ip)) {
> +			NL_SET_ERR_MSG(extack,
> +				       "Interface need to be specified for multicast destination");

needs

> +		if (conf->flags & VXLAN_F_IPV6_LINKLOCAL) {
> +			NL_SET_ERR_MSG(extack,
> +				       "Interface need to be specified for link-local local/remote addresses");

needs

Looks good to me otherwise, thanks!

 Jiri

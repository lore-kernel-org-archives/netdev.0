From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 0/2] mpls: multipath support
Date: Fri, 23 Oct 2015 05:14:32 -0700
Message-ID: <562A24A8.1050006@cumulusnetworks.com>
References: <1445559403-15258-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35026 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbJWMOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 08:14:33 -0400
Received: by pasz6 with SMTP id z6so117244137pas.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 05:14:33 -0700 (PDT)
In-Reply-To: <1445559403-15258-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/15, 5:16 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch adds support for MPLS multipath routes.
>
> Includes following changes to support multipath:
> - splits struct mpls_route into 'struct mpls_route + struct mpls_nh'.
>
> - struct mpls_nh represents a mpls nexthop label forwarding entry
>
> - Adds support to parse/fill RTA_MULTIPATH netlink attribute for
> multipath routes similar to ipv4/v6 fib
>
> - In the process of restructuring, this patch also consistently changes all
> labels to u8
>
> $ip -f mpls route add 100 nexthop as 200 via inet 10.1.1.2 dev swp1 \
> 		nexthop as 700 via inet 10.1.1.6 dev swp2 \
> 		nexthop as 800 via inet 40.1.1.2 dev swp3
>
> $ip  -f mpls route show
> 100 
> 	nexthop as to 200 via inet 10.1.1.2  dev swp1
> 	nexthop as to 700 via inet 10.1.1.6  dev swp2
> 	nexthop as to 800 via inet 40.1.1.2  dev swp3
>
> Roopa Prabhu (1):
>   mpls: multipath support
>
> Robert Shearman (1):
>   mpls: flow-based multipath selection
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
>
David, please ignore.  I will re-spin the series. I see a checkpatch error

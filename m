From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH 2/3] lwtunnel: Add encapsulation support to ip route
Date: Thu, 15 Oct 2015 18:51:46 +0200
Message-ID: <20151015185146.3e398790@griffin>
References: <cover.1444907416.git.tgraf@suug.ch>
	<79f6f592e3ca682392c2968b10cf821ca411acac.1444907416.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, mengke.liu@intel.com,
	tom@herbertland.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54958 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbbJOQvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2015 12:51:50 -0400
In-Reply-To: <79f6f592e3ca682392c2968b10cf821ca411acac.1444907416.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 15 Oct 2015 13:13:39 +0200, Thomas Graf wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> This patch adds support to parse and print lwtunnel
> encapsulation attributes attached to routes for MPLS
> and IP tunnels.
> 
> example:
> Add ipv4 route with mpls encap attributes:
> 
> Examples:
> 
>   MPLS:
>   $ ip route add 40.1.2.0/30 encap mpls 200 via inet 40.1.1.1 dev eth3
>   $ ip route show
>   40.1.2.0/30  encap mpls 200 via 40.1.1.1 dev eth3
> 
>   Add ipv4 multipath route with mpls encap attributes:
>   $ ip route add 10.1.1.0/30 nexthop encap mpls 200 via 10.1.1.1 dev eth0 \
> 		    nexthop encap mpls 700 via  40.1.1.2 dev eth3
>   $ ip route show
>   10.1.1.0/30
>     nexthop encap mpls 200  via 10.1.1.1  dev eth0 weight 1
>     nexthop encap mpls 700  via 40.1.1.2  dev eth3 weight 1
> 
>   IP:
>   $ ip route add 10.1.1.1/24 encap ip id 200 dst 20.1.1.1 dev vxlan0
> 
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc

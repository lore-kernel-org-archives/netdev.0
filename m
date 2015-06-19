From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next RFC v2 0/3] light weight tunnel infrastructure
 and driver
Date: Fri, 19 Jun 2015 15:38:36 +0100
Message-ID: <5584296C.1080108@brocade.com>
References: <1434689355-4088-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>, <ebiederm@xmission.com>,
	<tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:29322 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751391AbbFSOiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 10:38:51 -0400
In-Reply-To: <1434689355-4088-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/06/15 05:49, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This series implements infrastructure for light weight tunnels to support
> mpls label edge routers (ie mpls ip tunnels). As previously discussed
> having netdevices will not scale. Hence this series introduces new RTA_ENCAP*
> attributes to attach encap information with routes (following suggestion
> from Eric Biederman).

Looks promising, thanks for posting this series Roopa!

>
> The first patch introduces an infrastructure to support light weight tunnels
> that dont have netdevices. The infrastructure allows tunnel drivers
> to register handlers to parse and build tunnel encap data which can be attached
> to each route nexthop.
>
> The second patch adds support in ipv4 fib to carry such light weight tunnel
> encap data.

I presume this isn't ready to be merged until IPv6 is done, right?

>
> The third patch implements mpls ip tunnels using this light weight tunnel
> infrastructure.
>
> Could not think of a better name, so, it is 'lwt' for 'light weight tunnels'
> for now.

I can't think of a better name either.

Thanks,
Rob

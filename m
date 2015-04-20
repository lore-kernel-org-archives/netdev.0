From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [PATCH iproute2-next 2/2] netns: allow to dump and monitor nsid
Date: Mon, 20 Apr 2015 10:02:42 -0700
Message-ID: <20150420100242.0b21a78e@urahara>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
	<797e9129b12148228f163402c284dce6@HQ1WP-EXMB12.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:43594 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751907AbbDTRCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 13:02:49 -0400
In-Reply-To: <797e9129b12148228f163402c284dce6@HQ1WP-EXMB12.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Apr 2015 08:30:14 +0000
Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:

> Two commands are added:
>  - ip netns list-id
>  - ip monitor nsid
> 
> A cache is also added to remember the association between the iproute2 netns
> name (from /var/run/netns/) and the nsid.
> To avoid interfering with the rth socket, a new rtnl socket (rtnsh) is used to
> get nsid (we may send rtnl request during listing on rth).
> 
> Example:
> $ ip netns list-id
> nsid 0 (iproute2 netns name: foo)
> $ ip monitor nsid
> Deleted nsid 0 (iproute2 netns name: foo)
> nsid 16 (iproute2 netns name: bar)
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied with a couple of little style cleanups.

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH ipsec-next v2] xfrm: Use VRF master index if output device is enslaved
Date: Fri, 21 Aug 2015 02:11:21 +0300
Message-ID: <E97BEDFF-A3B2-41B4-A669-969E7052C75E@cumulusnetworks.com>
References: <1440108390-10192-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2098\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:35508 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752823AbbHTXLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 19:11:24 -0400
Received: by wicne3 with SMTP id ne3so2378109wic.0
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 16:11:23 -0700 (PDT)
In-Reply-To: <1440108390-10192-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Aug 21, 2015, at 1:06 AM, David Ahern <dsa@cumulusnetworks.com> wrote:
> 
> Directs route lookups to VRF table. Compiles out if NET_VRF is not
> enabled. With this patch able to successfully bring up ipsec tunnels
> in VRFs, even with duplicate network configuration.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - use vrf_master_ifindex rather than vrf_master_ifindex_rcu
> 
> net/ipv4/xfrm4_policy.c | 7 +++++--
> net/ipv6/xfrm6_policy.c | 7 +++++--
> 2 files changed, 10 insertions(+), 4 deletions(-)
> 

Looks good to me,

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

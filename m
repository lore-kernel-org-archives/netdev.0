From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch net-next v5 0/5] vxlan: add ipv6 support
Date: Sun, 21 Apr 2013 12:42:26 -0700
Message-ID: <20130421124226.3b2550e7@nehalam.linuxnetplumber.net>
References: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:57469 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754203Ab3DUTm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 15:42:59 -0400
Received: by mail-da0-f41.google.com with SMTP id p8so2600624dan.0
        for <netdev@vger.kernel.org>; Sun, 21 Apr 2013 12:42:59 -0700 (PDT)
In-Reply-To: <1366554192-27887-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 Apr 2013 22:23:07 +0800
Cong Wang <amwang@redhat.com> wrote:

> From: Cong Wang <amwang@redhat.com>
> 
> v5: make David happy on the names of the fields
>     fix my mistake during rebasing the patches
>     drop the scope_id patch, because it is broken
>     export in6addr_loopback
>     fix a udp checksum bug
>     rebased on the latest net-next
> 
> v4: rename ->sin to ->va_sin
>     rename ->sin6 to ->va_sin6
>     rename ->family to ->va_sa
>     support ll addr
>     fix more ugly #ifdef
>     rebased on the latest net-next
> 
> v3: fix many coding style issues
>     fix some ugly #ifdef
>     rename vxlan_ip to vxlan_addr
>     rename ->proto to ->family
>     rename ->ip4/->ip6 to ->sin/->sin6
> 
> v2: fix some compile error when !CONFIG_IPV6
>     improve some code based on Stephen's comments
>     use sockaddr suggested by David
> 
> Cong Wang (5):
>   vxlan: defer vxlan init as late as possible
>   ipv6: export ipv6_sock_mc_join and ipv6_sock_mc_drop
>   ipv6: export in6addr_loopback to modules
>   vxlan: add ipv6 support
>   ipv6: Add generic UDP Tunnel segmentation
> 
>  drivers/net/vxlan.c          |  625 ++++++++++++++++++++++++++++++++---------
>  include/uapi/linux/if_link.h |    2 +
>  net/ipv6/addrconf.c          |    9 -
>  net/ipv6/addrconf_core.c     |    9 +
>  net/ipv6/ip6_offload.c       |    4 +-
>  net/ipv6/mcast.c             |    2 +
>  net/ipv6/udp_offload.c       |  153 +++++++----
>  7 files changed, 609 insertions(+), 195 deletions(-)
> 

Looks good.
Acked-by: Stephen Hemminger <stephen@networkplumber.org>

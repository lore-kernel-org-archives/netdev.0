From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 net-next v2 0/3] ip netconf improvements
Date: Fri, 14 Apr 2017 16:02:31 -0700
Message-ID: <20170414160231.4ce987a9@xeon-e3>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35745 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754731AbdDNXCd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 19:02:33 -0400
Received: by mail-pf0-f171.google.com with SMTP id i5so45271429pfc.2
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 16:02:33 -0700 (PDT)
In-Reply-To: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Mar 2017 19:51:19 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> Currently, ip netconf only shows data for ipv4 and ipv6 for dumps
> and just ipv4 for device requests. Improve the user experience by
> using the new kernel patch to dump all address families that have
> registered. For example, if mpls_router module is loaded then mpls
> values are displayed along with ipv4 and ipv6.
> 
> If the new feature is not supported (new iproute2 on older kernel)
> the kernel returns the nlmsg error EOPNOTSUPP which can be trapped
> and fallback to existing behavior.
> 
> v2
> - fixed index conversion in patch 3 per nicholas' comment
> 
> David Ahern (3):
>   netlink: Add flag to suppress print of nlmsg error
>   ip netconf: Show all address families by default in dumps
>   ip netconf: show all families on dev request
> 
>  include/libnetlink.h |  1 +
>  ip/ipnetconf.c       | 36 +++++++++++++++++++++++++-----------
>  lib/libnetlink.c     |  3 ++-
>  3 files changed, 28 insertions(+), 12 deletions(-)
> 

Sure applied, just wanted to make sure there was nothing interrelated
with recent spate of changes to netlink notifications.

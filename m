From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [iproute2 net-next v2 0/3] ip netconf improvements
Date: Tue, 4 Apr 2017 17:07:31 -0400
Message-ID: <431908e0-27b0-730d-0c01-671702f30d71@cumulusnetworks.com>
References: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33087 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752352AbdDDVHe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:07:34 -0400
Received: by mail-io0-f182.google.com with SMTP id f84so103842135ioj.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:07:33 -0700 (PDT)
In-Reply-To: <1490323882-11609-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/23/17 10:51 PM, David Ahern wrote:
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

Hi Stephen: any comments? are you ok with this change?

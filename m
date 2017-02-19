From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 0/3] iplink: add support for link
 xstats
Date: Sat, 18 Feb 2017 16:38:43 -0800
Message-ID: <20170218163843.17f6c4f6@xeon-e3>
References: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34252 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbdBSArE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 19:47:04 -0500
Received: by mail-pg0-f45.google.com with SMTP id z67so25572262pgb.1
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 16:47:04 -0800 (PST)
In-Reply-To: <1487168593-31321-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Feb 2017 15:23:10 +0100
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> Hi,
> This set adds support for printing link xstats per link type. Currently
> only the bridge and its ports support such call and it dumps the mcast
> stats. This model makes it easy to use the same callback for both bridge
> and bridge_slave link types. Patch 01 also updates the man page with the
> new xstats link option and you can find an example in patch 02's commit
> message.
> 
> Thanks,
>  Nik
> 
> 
> Nikolay Aleksandrov (3):
>   iplink: add support for xstats subcommand
>   iplink: bridge: add support for displaying xstats
>   iplink: bridge_slave: add support for displaying xstats
> 
>  ip/Makefile              |   2 +-
>  ip/ip_common.h           |  12 +++-
>  ip/iplink.c              |   5 ++
>  ip/iplink_bridge.c       | 153 +++++++++++++++++++++++++++++++++++++++++++++++
>  ip/iplink_bridge_slave.c |   2 +
>  ip/iplink_xstats.c       |  81 +++++++++++++++++++++++++
>  man/man8/ip-link.8.in    |  12 ++++
>  7 files changed, 264 insertions(+), 3 deletions(-)
>  create mode 100644 ip/iplink_xstats.c
> 

Applied thanks. There was some minor fuzz on first batch due to other changes.

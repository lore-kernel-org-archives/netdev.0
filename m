From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: add support for afstats subcommand
Date: Fri, 10 Mar 2017 08:58:59 -0800
Message-ID: <20170310085859.10336dfd@xeon-e3>
References: <1489063416-26930-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33416 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755456AbdCJQ7C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 11:59:02 -0500
Received: by mail-pf0-f178.google.com with SMTP id w189so43900671pfb.0
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 08:59:02 -0800 (PST)
In-Reply-To: <1489063416-26930-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Mar 2017 12:43:36 +0000
Robert Shearman <rshearma@brocade.com> wrote:

> Add support for new afstats subcommand. This uses the new
> IFLA_STATS_AF_SPEC attribute of RTM_GETSTATS messages to show
> per-device, AF-specific stats. At the moment the kernel only supports
> MPLS AF stats, so that is all that's implemented here.
> 
> The print_num function is exposed from ipaddress.c to be used for
> printing the new stats so that the human-readable option, if set, can
> be respected.
> 
> Example of use:
> 
>     $ ./ip/ip -f mpls link afstats dev eth1
>     3: eth1
>         mpls:
>             RX: bytes  packets  errors  dropped  noroute
>             9016       98       0       0        0
>             TX: bytes  packets  errors  dropped
>             7232       113      0       0
> 
> Signed-off-by: Robert Shearman <rshearma@brocade.com>

Applied

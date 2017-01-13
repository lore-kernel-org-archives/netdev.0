From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/2] mpls: Packet stats
Date: Fri, 13 Jan 2017 14:50:04 -0800
Message-ID: <5879599C.4080509@cumulusnetworks.com>
References: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        David Ahern <dsa@cumulusnetworks.com>, ebiederm@xmission.com
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35310 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751232AbdAMWuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 17:50:07 -0500
Received: by mail-pf0-f175.google.com with SMTP id f144so37470865pfa.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 14:50:07 -0800 (PST)
In-Reply-To: <1484331253-5908-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/13/17, 10:14 AM, Robert Shearman wrote:
> This patchset records per-interface packet stats in the MPLS
> forwarding path and exports them using a nest of attributes root at a
> new IFLA_STATS_AF_SPEC attribute as part of RTM_GETSTATS messages:
>
> [IFLA_STATS_AF_SPEC]
>  -> [AF_MPLS]
>   -> [MPLS_STATS_LINK]
>    -> struct mpls_link_stats
>
> The first patch adds the rtnl infrastructure for this, including a new
> callbacks to per-AF ops of fill_stats_af and get_stats_af_size. The
> second patch records MPLS stats and makes use of the infrastructure to
> export them. The rtnl infrastructure could also be used to export IPv6
> stats in the future.
>
> Robert Shearman (2):
>   net: AF-specific RTM_GETSTATS attributes
>   mpls: Packet stats
>
LGTM, thanks Robert

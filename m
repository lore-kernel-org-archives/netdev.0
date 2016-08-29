From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v3] bridge: vlan: add support to
 display per-vlan statistics
Date: Mon, 29 Aug 2016 10:59:58 -0700
Message-ID: <20160829105958.66183ce3@xeon-e3>
References: <1472128135-17318-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:35677 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755647AbcH2R7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 13:59:55 -0400
Received: by mail-pf0-f175.google.com with SMTP id x72so54349802pfd.2
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 10:59:47 -0700 (PDT)
In-Reply-To: <1472128135-17318-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Aug 2016 14:28:55 +0200
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> This patch adds support for the stats argument to the bridge
> vlan command which will display the per-vlan statistics and the device
> each vlan belongs to with its flags. The supported command filtering
> options are dev and vid. Also the man page is updated to explain the new
> option.
> The patch uses the new RTM_GETSTATS interface with a filter_mask to dump
> all bridges and ports vlans. Later we can add support for using the
> per-device dump and filter it in the kernel instead.
> 
> Example:
> $ bridge -s vlan show
> port             vlan id
> br0               1 Egress Untagged
>                     RX: 2536 bytes 20 packets
>                     TX: 2536 bytes 20 packets
>                   101
>                     RX: 43158 bytes 50 packets
>                     TX: 43158 bytes 50 packets
> eth1              1 Egress Untagged
>                     RX: 2536 bytes 20 packets
>                     TX: 2536 bytes 20 packets
>                   100
>                     RX: 0 bytes 0 packets
>                     TX: 0 bytes 0 packets
>                   101
>                     RX: 43158 bytes 50 packets
>                     TX: 43158 bytes 50 packets
>                   102
>                     RX: 16897 bytes 93 packets
>                     TX: 0 bytes 0 packets
> 
> The format is the same as bridge vlan show but with stats, even though
> under the hood the calls done to the kernel are different.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---

Applied to net-next branch

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next 0/5] add latest bridge netlink options
Date: Tue, 17 Jan 2017 11:03:34 +0100
Message-ID: <6cad896d-8ea3-64c7-9137-55609bd38e35@cumulusnetworks.com>
References: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36376 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750747AbdAQKLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 05:11:50 -0500
Received: by mail-lf0-f45.google.com with SMTP id z134so99432424lff.3
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 02:11:50 -0800 (PST)
In-Reply-To: <1484645552-29440-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/01/17 10:32, Hangbin Liu wrote:
> Add the bridge netlink attributes added to kernel recently.
> 
> Hangbin Liu (5):
>   iplink: bridge: add support for IFLA_BR_FDB_FLUSH
>   iplink: bridge: add support for IFLA_BR_VLAN_STATS_ENABLED
>   iplink: bridge: add support for IFLA_BR_MCAST_STATS_ENABLED
>   iplink: bridge: add support for IFLA_BR_MCAST_IGMP_VERSION
>   iplink: bridge: add support for IFLA_BR_MCAST_MLD_VERSION
> 
>  ip/iplink_bridge.c | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 56 insertions(+), 1 deletion(-)
> 

Cool, I also have a version of all of these patches just didn't get around to send them yet. :-)
Anyway since you're at it, you should also add support for IFLA_BRPORT_FLUSH,
but TBH I don't think the flush attributes should be used via this command, they seem
like an action that you do rather than an option that you set. That is the reason I
didn't add support for them awhile back when I added the others. But I don't have a
strong feeling about doing it via ip link set or not, so if the others are fine, I'm good too.

Cheers,
 Nik

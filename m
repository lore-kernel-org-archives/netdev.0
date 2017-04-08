From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v3 iproute] ip: Add support for netdev events to monitor
Date: Sat, 8 Apr 2017 18:24:06 -0400
Message-ID: <0a7efd86-3345-223a-7a39-8c8cd1a42f14@cumulusnetworks.com>
References: <1491312333-18904-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        davem@davemloft.net
To: Vladislav Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:33854 "EHLO
        mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751685AbdDHWYJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 18:24:09 -0400
Received: by mail-qk0-f174.google.com with SMTP id p68so60805717qke.1
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 15:24:09 -0700 (PDT)
In-Reply-To: <1491312333-18904-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/17 9:25 AM, Vladislav Yasevich wrote:
> Add IFLA_EVENT handling so that event types can be viewed with
> 'monitor' command.  This gives a little more information for why
> a given message was receivied.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/if_link.h | 21 +++++++++++++++++++++
>  ip/ipaddress.c          | 31 +++++++++++++++++++++++++++++++
>  2 files changed, 52 insertions(+)

per comments on the email thread about reducing notifications, the
kernel patch for this should be reverted (and hence this iproute2 patch
is not needed) in favor of using a bitmask. Right now there are too many
redundant notifications to userspace.

Vlad: can you look at a bitmask version of IFLA_EVENT that shows what
changed in the newlink message from do_setlink()?

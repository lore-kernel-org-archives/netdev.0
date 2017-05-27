From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH V6 net-next 1/2] rtnl: Add support for netdev event to
 link messages
Date: Sat, 27 May 2017 15:41:28 -0600
Message-ID: <f05c6d50-ff95-6057-b2e5-bcc0c447b0c8@gmail.com>
References: <1495894476-9726-1-git-send-email-vyasevic@redhat.com>
 <1495894476-9726-2-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, jiri@resnulli.us, vfalico@gmail.com,
        andy@greyhouse.net, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35584 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750750AbdE0Vlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 17:41:31 -0400
Received: by mail-pf0-f194.google.com with SMTP id u26so8132836pfd.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 14:41:31 -0700 (PDT)
In-Reply-To: <1495894476-9726-2-git-send-email-vyasevic@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/27/17 8:14 AM, Vladislav Yasevich wrote:
> When netdev events happen, a rtnetlink_event() handler will send
> messages for every event in it's white list.  These messages contain
> current information about a particular device, but they do not include
> the iformation about which event just happened.  So, it is impossible
> to tell what just happend for these events.
> 
> This patch adds a new extension to RTM_NEWLINK message called IFLA_EVENT
> that would have an encoding of event that triggered this
> message.  This would allow the the message consumer to easily determine
> if it needs to perform certain actions.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  include/linux/rtnetlink.h    |  3 +-
>  include/uapi/linux/if_link.h | 11 ++++++++
>  net/core/dev.c               |  2 +-
>  net/core/rtnetlink.c         | 65 ++++++++++++++++++++++++++++++++++++++------
>  4 files changed, 70 insertions(+), 11 deletions(-)

Acked-by: David Ahern <dsahern@gmail.com>

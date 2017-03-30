From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] rtnl: Add support for netdev event to link
 messages
Date: Thu, 30 Mar 2017 15:41:31 -0600
Message-ID: <6d2145f8-48eb-2122-0284-510fb06bce84@cumulusnetworks.com>
References: <91c304f6-659f-01d7-a899-171142075276@cumulusnetworks.com>
 <1490887276-25158-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        netdev@vger.kernel.org, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34907 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934218AbdC3Vlc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 17:41:32 -0400
Received: by mail-pg0-f41.google.com with SMTP id 81so51048937pgh.2
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 14:41:31 -0700 (PDT)
In-Reply-To: <1490887276-25158-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/30/17 9:21 AM, Vladislav Yasevich wrote:
> 
> So, something like the patch below would be better in your opinion as a
> starting point.  It'll can at least get the discussion strarted on whether
> an event would usefull to user space or not.

IMO that is a more direct, explicit statement of what is intended to happen.

> 
> However, that's really a separate point from what I was originally try to do.
> I would like to provide the event type itself to the user, so the user may
> perform some action based on that event.


yes, we took a tangent. I was asking about why the PRECHANGEMTU was
causing a message to be sent to userspace.

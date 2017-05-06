From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH v4 net-next 0/2] rtnetlink: Updates to rtnetlink_event()
Date: Sat, 6 May 2017 12:51:30 +0200
Message-ID: <20170506105130.GE2017@nanopsycho>
References: <1494017569-12869-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35182 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751824AbdEFKvd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 06:51:33 -0400
Received: by mail-wm0-f67.google.com with SMTP id v4so906048wmb.2
        for <netdev@vger.kernel.org>; Sat, 06 May 2017 03:51:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1494017569-12869-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, May 05, 2017 at 10:52:47PM CEST, vyasevich@gmail.com wrote:
>This is a version 4 series came out of the conversation that started
>as a result my first attempt to add netdevice event info to netlink messages.
>
>First is the patch to add IFLA_EVENT attribute to the netlink message.  It
>supports only currently white-listed events.
>Like before, this is just an attribute that gets added to the rtnetlink
>message only when the messaged was generated as a result of a netdev event.
>In my case, this is necessary since I want to trap NETDEV_NOTIFY_PEERS
>event (also possibly NETDEV_RESEND_IGMP event) and perform certain actions
>in user space.  This is not possible since the messages generated as

What are you trying to do in userspace if I may ask.

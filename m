From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/8] rtnetlink: Do not generate notifications for
 MTU events
Date: Mon, 10 Apr 2017 09:49:55 -0600
Message-ID: <541c220b-9e55-8206-3886-6a98c86ae2e7@cumulusnetworks.com>
References: <1491600340-8359-1-git-send-email-dsa@cumulusnetworks.com>
 <1491600340-8359-2-git-send-email-dsa@cumulusnetworks.com>
 <58E92699.6090909@cumulusnetworks.com>
 <63e0a6c1-ec09-4f04-7e41-edd0adf871b2@cumulusnetworks.com>
 <58E92966.5000506@cumulusnetworks.com>
 <7dfa18fc-3e99-9630-7b3c-31823c66155a@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: vyasevic@redhat.com, Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:35478 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754596AbdDJPuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 11:50:03 -0400
Received: by mail-pg0-f52.google.com with SMTP id 81so107909763pgh.2
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 08:50:03 -0700 (PDT)
In-Reply-To: <7dfa18fc-3e99-9630-7b3c-31823c66155a@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 9:39 AM, Vlad Yasevich wrote:
> OK, so this will work for the events that are generated as a result of device state change
> (like mtu, address, and others).
> 
> However, the original event data may be needed for other events that may be
> of use to userspace like NETDEV_NOTIFY_PEERS and NETDEV_RESEND_IGMP (possibly others...)

sure. My objection is to multiple messages with identical content.

I think the rtnetlink_event message is unique for those 2 netdev events,
so no objections if it has value.

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 1/3] bridge: add new BR_NEIGH_SUPPRESS port
 flag to suppress arp and nd flood
Date: Thu, 5 Oct 2017 07:31:35 -0700
Message-ID: <CAJieiUi_3UxH8G1UUt1q8yQKsJC0YJr41M+q34xtS-ySkFAX=A@mail.gmail.com>
References: <1507093953-59929-1-git-send-email-roopa@cumulusnetworks.com>
 <1507093953-59929-2-git-send-email-roopa@cumulusnetworks.com> <20171004.155255.2208423870631197976.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:47201 "EHLO
        mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751409AbdJEObg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 10:31:36 -0400
Received: by mail-vk0-f48.google.com with SMTP id h63so8154352vka.4
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 07:31:36 -0700 (PDT)
In-Reply-To: <20171004.155255.2208423870631197976.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 4, 2017 at 3:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Tue,  3 Oct 2017 22:12:31 -0700
>
>> BR_ARP_PROXY flag but has a few semantic differences to conform
>
> This should be "BR_PROXYARP".

ack, will fix.

>
> Otherwise this series looks fine to me, but I see there will be
> a v5 respin.

yes, working on v5. I am currently testing a few more cases for
locally generated arp/nd packets with bridge as the src dev (related
to some questions from Toshiaki).

Thanks!.

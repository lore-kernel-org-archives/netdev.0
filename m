From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [RFC PATCH net-next v2] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Thu, 1 Dec 2016 09:55:25 -0800
Message-ID: <CAJieiUjPXNxXFJxPkbZUF03bfw_=0Dc9qG0CkYoE0qeXAn0kYg@mail.gmail.com>
References: <1480439718-18019-1-git-send-email-david.lebrun@uclouvain.be>
 <1480477952.3702850.803295033.367FD66D@webmail.messagingengine.com> <583E8646.2010402@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:34583 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750789AbcLARz1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 12:55:27 -0500
Received: by mail-ua0-f182.google.com with SMTP id 51so255832080uai.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 09:55:26 -0800 (PST)
In-Reply-To: <583E8646.2010402@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 11:56 PM, David Lebrun
<david.lebrun@uclouvain.be> wrote:
> On 11/30/2016 04:52 AM, Hannes Frederic Sowa wrote:

>
>> Also please convert the sysctl to a netlink attribute if you pursue this
>> because if I change the sysctl while my quagga is hammering the routing
>> table I would like to know which nodes allocate what amount of memory.
>
> Yes, that was the idea.
>

I think Its best for it to be a global setting, and thats why sysctl
seems like the best way (unless there are other ways to set this
globally via rtnetlink). If it helps, most hw switch vendors
supporting this feature also provide a globally tunable knob and it is
not on by default.

From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2] net: Require exact match for TCP socket lookups if dif
 is l3mdev
Date: Fri, 14 Oct 2016 09:28:15 -0600
Message-ID: <f82e5e6d-d32d-d5dc-5484-f3f2ab76450b@cumulusnetworks.com>
References: <1476420459-20966-1-git-send-email-dsa@cumulusnetworks.com>
 <1476426789.5650.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <25e3a7a9-a74e-5392-742a-38bd224343f6@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:36124 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753945AbcJNP2S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 11:28:18 -0400
Received: by mail-pf0-f177.google.com with SMTP id e6so51038479pfk.3
        for <netdev@vger.kernel.org>; Fri, 14 Oct 2016 08:28:18 -0700 (PDT)
In-Reply-To: <25e3a7a9-a74e-5392-742a-38bd224343f6@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/16 6:21 AM, David Ahern wrote:
>> So you might need to let the caller pass IP6CB(skb)->flags (or
>> TCP_SKB_CB(skb)->header.h6.flags ) instead of skb since
>> inet6_exact_dif_match() does not know where to fetch the flags.
>>
>> Same issue for IPv4.
> 
> I'll update the match functions to pull from TCP_SKB_CB instead of IP6CB and make a note of the above.

IPv6 does the move after the socket lookup where IPv4 does it before.

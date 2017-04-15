From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Fri, 14 Apr 2017 18:42:14 -0600
Message-ID: <1f3828b5-6fce-ac9c-6be0-80352aef06de@cumulusnetworks.com>
References: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
 <479839ac1ff57240a61f43d7b128a2a3@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Robert Shearman <rshearma@brocade.com>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33312 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755707AbdDOAmQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 20:42:16 -0400
Received: by mail-pg0-f48.google.com with SMTP id x125so49007494pgb.0
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 17:42:16 -0700 (PDT)
In-Reply-To: <479839ac1ff57240a61f43d7b128a2a3@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/17 6:38 PM, Subash Abhinov Kasiviswanathan wrote:
> On 2017-04-14 16:23, David Ahern wrote:
>> Subash:
>>
>> My understanding of early demux is that it should only match connected
>> sockets (src/sport + dst/dport are all set). The ipv6 udp early demux
>> code added in 5425077d73e0c is doing a generic socket lookup which does
>> not require an exact match and accordingly breaks udp_l3mdev_accept=0.
>> Please fix.
>>
>> David
> 
> Hi David
> 
> Would it be possible to disable udp_early_demux for your case temporarily.
> I'll look into this.
> 

It should be fixed for 4.12. Basically, __udp6_lib_demux_lookup needs to
be more like __udp4_lib_demux_lookup

From: David Miller <davem@davemloft.net>
Subject: Re: ipv6 udp early demux breaks udp_l3mdev_accept=0
Date: Sat, 15 Apr 2017 09:48:10 -0400 (EDT)
Message-ID: <20170415.094810.1393827754237126920.davem@davemloft.net>
References: <0c7198e6-7dde-917b-9c10-4e1835e38319@cumulusnetworks.com>
        <479839ac1ff57240a61f43d7b128a2a3@codeaurora.org>
        <1f3828b5-6fce-ac9c-6be0-80352aef06de@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, netdev@vger.kernel.org,
        rshearma@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdDONsO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 09:48:14 -0400
In-Reply-To: <1f3828b5-6fce-ac9c-6be0-80352aef06de@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Fri, 14 Apr 2017 18:42:14 -0600

> On 4/14/17 6:38 PM, Subash Abhinov Kasiviswanathan wrote:
>> On 2017-04-14 16:23, David Ahern wrote:
>>> Subash:
>>>
>>> My understanding of early demux is that it should only match connected
>>> sockets (src/sport + dst/dport are all set). The ipv6 udp early demux
>>> code added in 5425077d73e0c is doing a generic socket lookup which does
>>> not require an exact match and accordingly breaks udp_l3mdev_accept=0.
>>> Please fix.
>>>
>>> David
>> 
>> Hi David
>> 
>> Would it be possible to disable udp_early_demux for your case temporarily.
>> I'll look into this.
>> 
> 
> It should be fixed for 4.12. Basically, __udp6_lib_demux_lookup needs to
> be more like __udp4_lib_demux_lookup

Agreed.

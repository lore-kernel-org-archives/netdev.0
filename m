From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: ipv6: Improve user experience
 with multipath routes
Date: Thu, 26 Jan 2017 13:00:54 -0500 (EST)
Message-ID: <20170126.130054.2221154789287701062.davem@davemloft.net>
References: <20170124.110616.2098461870069191491.davem@davemloft.net>
        <4024f547-7f26-ab52-df9d-a0509048c7ff@6wind.com>
        <c78afc85-8d18-0f63-68b3-63925e5d8c81@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35598 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753029AbdAZSME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 13:12:04 -0500
In-Reply-To: <c78afc85-8d18-0f63-68b3-63925e5d8c81@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 26 Jan 2017 10:26:51 -0700

> On 1/26/17 7:58 AM, Nicolas Dichtel wrote:
>> Le 24/01/2017 à 17:06, David Miller a écrit :
>>> From: David Ahern <dsa@cumulusnetworks.com>
>>> Date: Fri, 20 Jan 2017 12:31:44 -0700
>>>
>>>> BTW, I am in favor of not requiring a user API for this but just
>>>> doing it. I can't imagine anyone working with multipath routes not
>>>> wanting the efficiency of the RTA_MULTIPATH attribute. These patches
>>>> require an API only because of the rule not to break userspace. If
>>>> we conclude to just do it without an API, the multipath_add and
>>>> multipath_del need to be modified to only send a notification once
>>>> at the end of the actions.
>>>
>>> After some consideration, I agree.
>> Sorry for my late reply but I fear that this will break some userland apps like
>> quagga.
> 
> Quagga does not properly handle IPv6 multipath routes received from
> the kernel. I checked this with debian/jessie version and our
> version, and Donald reviewed the source. It is broken.

If this is true, quagga is asbolutely not an argument for this "breaking"
something.  It doesn't break anything.

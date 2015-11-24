From: David Miller <davem@davemloft.net>
Subject: Re: MULTIPLE_TABLES and IP_ADVANCED_ROUTER
Date: Tue, 24 Nov 2015 14:06:36 -0500 (EST)
Message-ID: <20151124.140636.1407559679495101433.davem@davemloft.net>
References: <CAMuHMdXZpxnrU=FfFcf3sgX+Ym3RCVLA7dn_8mgUBpby18uDzw@mail.gmail.com>
	<20151124.131025.2229181704954661538.davem@davemloft.net>
	<CAMuHMdUvOZGPpR9ipNd=OxpWsHcDSbSiX+=HG1nxOJKSpeOm6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbbKXTGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 14:06:39 -0500
In-Reply-To: <CAMuHMdUvOZGPpR9ipNd=OxpWsHcDSbSiX+=HG1nxOJKSpeOm6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 24 Nov 2015 19:38:13 +0100

> Hi David,
> 
> On Tue, Nov 24, 2015 at 7:10 PM, David Miller <davem@davemloft.net> wrote:
>> From: Geert Uytterhoeven <geert@linux-m68k.org>
>> Date: Sun, 22 Nov 2015 11:03:18 +0100
>>
>>> Is there a reason why IP_MULTIPLE_TABLES and
>>> IP_MROUTE_MULTIPLE_TABLES depend on IP_ADVANCED_ROUTER, while their
>>> IPV6 counterparts don't?
>>
>> It's just another thing that happened to diverge over time, there is
>> no real reason.
> 
> So should the dependencies be added for IPv6, or removed for IPv4?

I think either change risks breaking something for someone, for
extremely questionable gains, so leaving things as they are is
probably the most prudent thing to do.

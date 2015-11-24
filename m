From: Cong Wang <cwang@twopensource.com>
Subject: Re: MULTIPLE_TABLES and IP_ADVANCED_ROUTER
Date: Tue, 24 Nov 2015 10:43:33 -0800
Message-ID: <CAHA+R7O2M_CW7TbVdsRMO+GBE0RwkctODHtYq+m3_-Zq11zn4A@mail.gmail.com>
References: <CAMuHMdXZpxnrU=FfFcf3sgX+Ym3RCVLA7dn_8mgUBpby18uDzw@mail.gmail.com>
	<20151124.131025.2229181704954661538.davem@davemloft.net>
	<CAMuHMdUvOZGPpR9ipNd=OxpWsHcDSbSiX+=HG1nxOJKSpeOm6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:34176 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754899AbbKXSne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:43:34 -0500
Received: by ykfs79 with SMTP id s79so29619324ykf.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:43:33 -0800 (PST)
In-Reply-To: <CAMuHMdUvOZGPpR9ipNd=OxpWsHcDSbSiX+=HG1nxOJKSpeOm6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2015 at 10:38 AM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
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

David's point is we should just leave it as it is.

From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH net-next] net: remove sk_init() helper
Date: Wed, 26 Sep 2012 11:51:31 +0800
Message-ID: <50627BC3.7030107@gmail.com>
References: <1348608733.26828.3492.camel@edumazet-glaptop>  <5062636E.2060200@gmail.com> <1348626205.26828.3563.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:37505 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab2IZDvk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2012 23:51:40 -0400
Received: by pbbrr4 with SMTP id rr4so1195309pbb.19
        for <netdev@vger.kernel.org>; Tue, 25 Sep 2012 20:51:39 -0700 (PDT)
In-Reply-To: <1348626205.26828.3563.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet said, at 2012/9/26 10:23:
> On Wed, 2012-09-26 at 10:07 +0800, Shan Wei wrote:
>> Eric Dumazet said, at 2012/9/26 5:32:
>>> From: Eric Dumazet <edumazet@google.com>
>>>
>>> It seems sk_init() has no value today and even does strange things :
>>>
>>> # grep . /proc/sys/net/core/?mem_*
>>> /proc/sys/net/core/rmem_default:212992
>>> /proc/sys/net/core/rmem_max:131071
>>> /proc/sys/net/core/wmem_default:212992
>>> /proc/sys/net/core/wmem_max:131071
>>>
>>> We can remove it completely.
>>
>> Ye, I have reported this problem.
>> http://lists.openwall.net/netdev/2012/04/27/49
>>
>> How about for small RAM ~16M?
> 
> It was maybe a concern 20 years ago, ( I ran linux on [34]86 computers
> with 12 or 16 MB of memory) but this makes no sense today with linux-3.7

I never play so lower memory computer. :-(
And now so lower memory device die out.

Reviewed-by: Shan Wei <davidshan@tencent.com>

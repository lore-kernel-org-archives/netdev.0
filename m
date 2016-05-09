From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: IPv6: proxy_ndp to a network range
Date: Mon, 09 May 2016 01:46:13 -0700
Message-ID: <A2319CD4-6907-4B21-A4DD-03CCA38328FA@zytor.com>
References: <31ff66eb-38bd-0186-9e81-0543f0558323@zytor.com> <20160509083903.GA2462@omega>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:54840 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751384AbcEIIrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 04:47:01 -0400
In-Reply-To: <20160509083903.GA2462@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On May 9, 2016 1:39:08 AM PDT, Alexander Aring <alex.aring@gmail.com> wrote:
>Hi,
>
>On Mon, May 09, 2016 at 01:06:51AM -0700, H. Peter Anvin wrote:
>> Hello,
>> 
>> There currently doesn't seem to be any support for proxy_ndp of a
>whole
>> network mask, as IPv4 proxy_arp seems to permit.
>> 
>> a) Am I actually correct in this, or am I just missing something
>important?
>> 
>> b) Is there a technical reason for this, or is it just a limitation
>of the
>> current implementation?
>> 
>
>So far I know you can do this with the ndppd [0] userspace tool which
>listen
>NS/NA messages and do the ip -6 neigh add proxy for you.
>
>- Alex
>
>[0] https://github.com/DanielAdolfsson/ndppd

Sure, but it seems like a workaround for something that ought to be simpler?
-- 
Sent from my Android device with K-9 Mail. Please excuse brevity and formatting.

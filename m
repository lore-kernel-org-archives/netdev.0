From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: remove Appropriate Byte Count support
Date: Tue, 05 Feb 2013 14:46:35 -0500 (EST)
Message-ID: <20130205.144635.1648371589019378147.davem@davemloft.net>
References: <20130205092517.58d11171@nehalam.linuxnetplumber.net>
	<CAK6E8=dCgNgGpQK=oMBz3c0c8Scj4nwi5OS7r4QWrrxhiJsXFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111Ab3BETqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:46:36 -0500
In-Reply-To: <CAK6E8=dCgNgGpQK=oMBz3c0c8Scj4nwi5OS7r4QWrrxhiJsXFw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Tue, 5 Feb 2013 09:47:59 -0800

> On Tue, Feb 5, 2013 at 9:25 AM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> TCP Appropriate Byte Count was added by me, but later disabled.
>> There is no point in maintaining it since it is a potential source
>> of bugs and Linux already implements other better window protection
>> heuristics.
> +1
> 
>>
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, and:

>>         tp->bytes_acked = 0;
> Is bytes_acked still needed?

I took care of this when I committed Stephen's patch.

Thanks.

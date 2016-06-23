From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Thu, 23 Jun 2016 03:40:04 -0400 (EDT)
Message-ID: <20160623.034004.1518087003165708123.davem@davemloft.net>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
	<CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: richard.weinberger@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbcFWHkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 03:40:10 -0400
In-Reply-To: <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Weinberger <richard.weinberger@gmail.com>
Date: Thu, 23 Jun 2016 00:15:04 +0200

> On Thu, Jun 16, 2016 at 7:51 PM, Tom Herbert <tom@herbertland.com> wrote:
>> Transports over UDP is intended to encapsulate TCP and other transport
>> protocols directly and securely in UDP.
>>
>> The goal of this work is twofold:
>>
>> 1) Allow applications to run their own transport layer stack (i.e.from
>>    userspace). This eliminates dependencies on the OS (e.g. solves a
>>    major dependency issue for Facebook on clients).
> 
> Facebook on clients would be a Facebook app on mobile devices?
> Does that mean that the Facebook app is so advanced and complicated
> that it needs a special TCP stack?!

No, the TCP stack in the android/iOS/Windows kernel is so out of date
that in order to get even moderately recent TCP features it is
necessary to do this.

That's the point.

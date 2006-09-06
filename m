From: Chase Venters <chase.venters@clientec.com>
Subject: Re: [take16 1/4] kevent: Core files.
Date: Wed, 6 Sep 2006 08:54:22 -0500 (CDT)
Message-ID: <Pine.LNX.4.64.0609060850150.18512@turbotaz.ourhouse>
References: <1157543723488@2ka.mipt.ru> <Pine.LNX.4.64.0609060824090.18512@turbotaz.ourhouse>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay03.pair.com ([209.68.5.17]:56586 "HELO relay03.pair.com")
	by vger.kernel.org with SMTP id S1751062AbWIFN5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 09:57:07 -0400
To: Chase Venters <chase.venters@clientec.com>
In-Reply-To: <Pine.LNX.4.64.0609060824090.18512@turbotaz.ourhouse>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 6 Sep 2006, Chase Venters wrote:

>>  +	if (start + num >= KEVENT_MAX_EVENTS ||
>>  +			start >= KEVENT_MAX_EVENTS ||
>>  +			num >= KEVENT_MAX_EVENTS)
>
> Since start and num are unsigned, the last two checks are redundant. If start 
> or num is individually >= KEVENT_MAX_EVENTS, start + num must be.
>

Actually, my early-morning brain code optimizer is apparently broken, 
because it forgot all about integer wraparound. Disregard please.

>
> Thanks,
> Chase
>

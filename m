From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 24 Jun 2016 17:01:04 -0700
Message-ID: <576DC9C0.4080102@hpe.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net>
 <576B94DA.7070804@nod.at>
 <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
 <576DA7C4.7040108@hpe.com>
 <CALx6S34Vu_xG7jjTSdFXdbkJOfKt=639ji5DX4gOjObi8Nf+7A@mail.gmail.com>
 <576DAEF9.8080501@hpe.com>
 <CALx6S37e5uQ9RXzVaAmAD=rpeqpwDizRQML9G6XCjCf273Gr1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hpe.com ([15.233.44.26]:7014 "EHLO
	g2t2353.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbcFYABG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 20:01:06 -0400
In-Reply-To: <CALx6S37e5uQ9RXzVaAmAD=rpeqpwDizRQML9G6XCjCf273Gr1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2016 04:43 PM, Tom Herbert wrote:
> Here's Christoph's slides on TFO in the wild which presents a good
> summary of the middlebox problem. There is one significant difference
> in that ECN needs network support whereas TFO didn't. Given that
> experience, I'm doubtful other new features at L4 could ever be
> productively use (like EDO or maybe TCP-ENO).
>
> https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf

Perhaps I am being overly optimistic, but my takeaway from those slides 
is Apple were able to come-up with ways to deal with the middleboxes and 
so could indeed productively use TCP FastOpen.

"Overall, very good success-rate"
though tempered by
"But... middleboxes were a big issue in some ISPs..."

Though it doesn't get into how big (some connections, many, most, all?) 
and how many ISPs.

rick jones

Just an anecdote...  Not that I am a "power user" of my iPhone running 
9.3.2 (13F69) nor that I know that anything I am using is the Apple 
Service stated as using TFO (mostly Safari, Mail and Messages) but if it 
is, I cannot say that any troubles under the covers have been noticed by me.

From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 24 Jun 2016 16:43:05 -0700
Message-ID: <CALx6S37e5uQ9RXzVaAmAD=rpeqpwDizRQML9G6XCjCf273Gr1A@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net> <576B94DA.7070804@nod.at>
 <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
 <576DA7C4.7040108@hpe.com> <CALx6S34Vu_xG7jjTSdFXdbkJOfKt=639ji5DX4gOjObi8Nf+7A@mail.gmail.com>
 <576DAEF9.8080501@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:37876 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080AbcFXXnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 19:43:07 -0400
Received: by mail-it0-f51.google.com with SMTP id f6so25370470ith.0
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 16:43:07 -0700 (PDT)
In-Reply-To: <576DAEF9.8080501@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 3:06 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 06/24/2016 02:46 PM, Tom Herbert wrote:
>>
>> On Fri, Jun 24, 2016 at 2:36 PM, Rick Jones <rick.jones2@hpe.com> wrote:
>>>
>>> How would you define "severely?"  Has it actually been more severe than
>>> for
>>> say ECN?  Or it was for say SACK or PAWS?
>>>
>> ECN is probably even a bigger disappointment in terms of seeing
>> deployment :-( From http://ecn.ethz.ch/ecn-pam15.pdf:
>>
>> "Even though ECN was standardized in 2001, and it is widely
>> implemented in end-systems, it is barely deployed. This is due to a
>> history of problems with severely broken middleboxes shortly after
>> standardization, which led to connectivity failure and guidance to
>> leave ECN disabled."
>>
>> SACK and PAWS seemed to have faired a little better I believe.
>
>
> The conclusion of that (rather interesting) paper reads:
>
> "Our analysis therefore indicates that enabling ECN by default would
> lead to connections to about five websites per thousand to suffer
> additional setup latency with RFC 3168 fallback. This represents an
> order of magnitude fewer than the about forty per thousand which
> experience transient or permanent connection failure due to other
> operational issues"
>
> Doesn't that then suggest that not enabling ECN is basically a matter of FUD
> more than remaining assumed broken middleboxes?
>
> My main point is that in the past at least, trouble with broken middleboxes
> didn't lead us to start wrapping all our TCP/transport traffic in UDP to try
> to hide it from them.  We've managed to get SACK and PAWS universal without
> having to resort to that, and it would seem we could get ECN universal if we
> could overcome our FUD.  Why would TFO for instance be any different?
>
Here's Christoph's slides on TFO in the wild which presents a good
summary of the middlebox problem. There is one significant difference
in that ECN needs network support whereas TFO didn't. Given that
experience, I'm doubtful other new features at L4 could ever be
productively use (like EDO or maybe TCP-ENO).

https://www.ietf.org/proceedings/94/slides/slides-94-tcpm-13.pdf

Tom

> There was an equally interesting second paragraph in the conclusion:
>
> "As not all websites are equally popular, failures on five per thousand
> websites does not by any means imply that five per thousand connection
> attempts will fail. While estimation of connection attempt rate by rank is
> out of scope of this work, we note that the highest ranked website
> exhibiting stable connection failure has rank 596, and only 13 such sites
> appear in the top 5000"
>
> rick jones

From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 24 Jun 2016 15:06:49 -0700
Message-ID: <576DAEF9.8080501@hpe.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net>
 <576B94DA.7070804@nod.at>
 <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
 <576DA7C4.7040108@hpe.com>
 <CALx6S34Vu_xG7jjTSdFXdbkJOfKt=639ji5DX4gOjObi8Nf+7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:47833 "EHLO
	g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbcFXWGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 18:06:53 -0400
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com [15.241.48.72])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 5154C243
	for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 22:06:52 +0000 (UTC)
In-Reply-To: <CALx6S34Vu_xG7jjTSdFXdbkJOfKt=639ji5DX4gOjObi8Nf+7A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/24/2016 02:46 PM, Tom Herbert wrote:
> On Fri, Jun 24, 2016 at 2:36 PM, Rick Jones <rick.jones2@hpe.com> wrote:
>> How would you define "severely?"  Has it actually been more severe than for
>> say ECN?  Or it was for say SACK or PAWS?
>>
> ECN is probably even a bigger disappointment in terms of seeing
> deployment :-( From http://ecn.ethz.ch/ecn-pam15.pdf:
>
> "Even though ECN was standardized in 2001, and it is widely
> implemented in end-systems, it is barely deployed. This is due to a
> history of problems with severely broken middleboxes shortly after
> standardization, which led to connectivity failure and guidance to
> leave ECN disabled."
>
> SACK and PAWS seemed to have faired a little better I believe.

The conclusion of that (rather interesting) paper reads:

"Our analysis therefore indicates that enabling ECN by default would
lead to connections to about five websites per thousand to suffer
additional setup latency with RFC 3168 fallback. This represents an
order of magnitude fewer than the about forty per thousand which
experience transient or permanent connection failure due to other
operational issues"

Doesn't that then suggest that not enabling ECN is basically a matter of 
FUD more than remaining assumed broken middleboxes?

My main point is that in the past at least, trouble with broken 
middleboxes didn't lead us to start wrapping all our TCP/transport 
traffic in UDP to try to hide it from them.  We've managed to get SACK 
and PAWS universal without having to resort to that, and it would seem 
we could get ECN universal if we could overcome our FUD.  Why would TFO 
for instance be any different?

There was an equally interesting second paragraph in the conclusion:

"As not all websites are equally popular, failures on five per thousand
websites does not by any means imply that five per thousand connection 
attempts will fail. While estimation of connection attempt rate by rank 
is out of scope of this work, we note that the highest ranked website 
exhibiting stable connection failure has rank 596, and only 13 such 
sites appear in the top 5000"

rick jones

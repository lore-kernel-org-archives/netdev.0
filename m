From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 24 Jun 2016 14:46:11 -0700
Message-ID: <CALx6S34Vu_xG7jjTSdFXdbkJOfKt=639ji5DX4gOjObi8Nf+7A@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net> <576B94DA.7070804@nod.at>
 <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com> <576DA7C4.7040108@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Richard Weinberger <richard@nod.at>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:36411 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183AbcFXVqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 17:46:12 -0400
Received: by mail-io0-f170.google.com with SMTP id s63so106328508ioi.3
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 14:46:12 -0700 (PDT)
In-Reply-To: <576DA7C4.7040108@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 24, 2016 at 2:36 PM, Rick Jones <rick.jones2@hpe.com> wrote:
> On 06/24/2016 02:12 PM, Tom Herbert wrote:
>>
>> The client OS side is only part of the story. Middlebox intrusion at
>> L4 is also a major issue we need to address. The "failure" of TFO is a
>> good case study. Both the upgrade issues on clients and the tendency
>> for some middleboxes to drop SYN packets with data have together
>> severely hindered what otherwise should have been straightforward and
>> useful feature to deploy.
>
>
> How would you define "severely?"  Has it actually been more severe than for
> say ECN?  Or it was for say SACK or PAWS?
>
ECN is probably even a bigger disappointment in terms of seeing
deployment :-( From http://ecn.ethz.ch/ecn-pam15.pdf:

"Even though ECN was standardized in 2001, and it is widely
implemented in end-systems, it is barely deployed. This is due to a
history of problems with severely broken middleboxes shortly after
standardization, which led to connectivity failure and guidance to
leave ECN disabled."

SACK and PAWS seemed to have faired a little better I believe.

Tom

> rick jones
>

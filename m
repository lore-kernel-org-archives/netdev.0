From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 0/6] net-timestamp: new tx tstamps and tcp
Date: Thu, 7 Aug 2014 19:39:56 -0400
Message-ID: <CA+FuTSen+eX-0VW+2vgt=ecaM8Wz1bKHXgiMk=UcAtepR1ewCQ@mail.gmail.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com> <87lhqzkic9.fsf@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:49399 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780AbaHGXk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:40:27 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so5162548qgf.21
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2014 16:40:26 -0700 (PDT)
In-Reply-To: <87lhqzkic9.fsf@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 7, 2014 at 7:09 PM, Andi Kleen <andi@firstfloor.org> wrote:
> Willem de Bruijn <willemb@google.com> writes:
>
>> Extend socket tx timestamping:
>> - allow multiple types of software timestamps aside from send (1)
>> - add software timestamp on enter packet scheduling (4)
>> - add software timestamp for TCP (5)
>> - add software timestamp for TCP on ACK (6)
>
> Is there any freely available reference library or tool to make use of
> all these new time stamps?

I posted one on github.com/wdebruij/kerneltools earlier, but the
interface has changed in the meantime. I just updated it to work with
the latest API.

There are still references to the old MSG_TSTAMP API in the test file
(txtimestamp.c), so I will need to clean it up some more. But it
works as is.

The v1 patchset also had a patch to the documentation. I will revise
that to match the latest interface, too, and send both files for
inclusion in Documention once net-next opens.

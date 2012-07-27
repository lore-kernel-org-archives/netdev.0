From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH v2 0/7] TCP Fast Open client
Date: Fri, 27 Jul 2012 10:28:11 -0700
Message-ID: <CAPshTCjxUQ=juO3POX1oSaLTO_g3EmxjQNkSxLjEZGyxDBkMJQ@mail.gmail.com>
References: <1342645307-17772-1-git-send-email-ycheng@google.com>
	<CAHO5Pa0D-hS=zdEEyUWMN6bmpKvQgiy25nTu1=BUYVxec+zpsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Yuchung Cheng <ycheng@google.com>, davem@davemloft.net,
	edumazet@google.com, ncardwell@google.com, sivasankar@cs.ucsd.edu,
	netdev@vger.kernel.org, rick jones <perfgeek@mac.com>,
	Terry Lam <vtlam@cs.ucsd.edu>
To: Michael Kerrisk <mtk.manpages@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:59967 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751081Ab2G0R2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 13:28:13 -0400
Received: by lahd3 with SMTP id d3so2304079lah.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 10:28:12 -0700 (PDT)
In-Reply-To: <CAHO5Pa0D-hS=zdEEyUWMN6bmpKvQgiy25nTu1=BUYVxec+zpsQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+rick, terry

Hi Michael,

Thanks for your interest!

On Fri, Jul 27, 2012 at 4:42 AM, Michael Kerrisk <mtk.manpages@gmail.com> wrote:
> Yuchung,
>
> On Wed, Jul 18, 2012 at 11:01 PM, Yuchung Cheng <ycheng@google.com> wrote:
>> ChangeLog since v1:
>>   - Reduce tons of code by storing Fast Open stats in the TCP metrics :)
>>   - Clarify the purpose of using an experimental option in patch 1/7
>>
>> This patch series implement the client functionality of TCP Fast Open.
>> TCP Fast Open (TFO) allows data to be carried in the SYN and SYN-ACK
>> packets and consumed by the receiving end during the initial connection
>> handshake, thus providing a saving of up to one full round trip time (RTT)
>> compared to standard TCP requiring a three-way handshake (3WHS) to
>> complete before data can be exchanged.
>>
>> The protocol change is detailed in the IETF internet draft at
>> http://www.ietf.org/id/draft-ietf-tcpm-fastopen-00.txt . The research
>
> This URL appears to be invalid. I assume the following is the correct
> current version:
> http://tools.ietf.org/html/draft-ietf-tcpm-fastopen-01
> ?

Correct.

>
> Is there some sample client and server userspace test code available?

There are some sample code in a SIGCOMM paper (
http://conferences.sigcomm.org/co-next/2011/papers/1569470463.pdf). It's
real simple but we haven't published the server side code yet. (It's been
ready but I need to rebase it to the latest net-next.)

We will also be working with Rick Jones to add the Fast Open support to
netperf.

Best,

Jerry

>
> Thanks,
>
> Michael
>
> --
> Michael Kerrisk Linux man-pages maintainer;
> http://www.kernel.org/doc/man-pages/
> Author of "The Linux Programming Interface", http://blog.man7.org/

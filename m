From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 19:11:21 +0200
Message-ID: <54132939.3090104@redhat.com>
References: <5412D9B9.2020300@redhat.com> <3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org> <20140912160559.GA34038@its-macbook-pro.westell.com> <CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10630 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751408AbaILRLq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Sep 2014 13:11:46 -0400
In-Reply-To: <CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/12/2014 07:06 PM, Cong Wang wrote:
> On Fri, Sep 12, 2014 at 9:06 AM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
>> On Fri, Sep 12, 2014 at 02:04:43PM +0200, Hannes Frederic Sowa wrote:
>>> Currently we have 2 pkt_type_offset functions doing the same thing and
>>> spread across the architecture files. Remove those and replace them
>>> with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
>>> zero sized sk_buff member right in front of the bitfield with offsetof.
>>> This new offset marker does not change size of struct sk_buff.
>>>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>> Cc: Markos Chandras <markos.chandras@imgtec.com>
>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>> Cc: Daniel Borkmann <dborkman@redhat.com>
>>> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> ---
>>>
>>> v2) Incorporated Daniel's feedback. I first misinterpreted the feedback
>>>      as something not related to pkt_type_offset.
>>
>> Thanks! It's a nice cleanup.
>>
>> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Wait... Isn't there a same patch before?
>
> http://www.spinics.net/lists/netdev/msg294839.html
>
> Maybe not exactly the same, but roughly same from the stats....

Yes, this is what the whole discussion is about, to unify it to a
central place.

From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next v2] net: filter: constify detection of pkt_type_offset
Date: Fri, 12 Sep 2014 10:06:12 -0700
Message-ID: <CAHA+R7NgqNSkcffcOWr9t6OqjTvfnrLZJdicpwYY91EWNZxyZA@mail.gmail.com>
References: <5412D9B9.2020300@redhat.com>
	<3e68956a7e5b8bb9de226bfcc09092c6852a0a0a.1410523297.git.hannes@stressinduktion.org>
	<20140912160559.GA34038@its-macbook-pro.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Denis Kirjanov <kda@linux-powerpc.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:50647 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbaILRGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 13:06:14 -0400
Received: by mail-la0-f50.google.com with SMTP id ty20so1356799lab.9
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 10:06:12 -0700 (PDT)
In-Reply-To: <20140912160559.GA34038@its-macbook-pro.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 12, 2014 at 9:06 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Sep 12, 2014 at 02:04:43PM +0200, Hannes Frederic Sowa wrote:
>> Currently we have 2 pkt_type_offset functions doing the same thing and
>> spread across the architecture files. Remove those and replace them
>> with a PKT_TYPE_OFFSET macro helper which gets the constant value from a
>> zero sized sk_buff member right in front of the bitfield with offsetof.
>> This new offset marker does not change size of struct sk_buff.
>>
>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>> Cc: Markos Chandras <markos.chandras@imgtec.com>
>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>> Cc: Daniel Borkmann <dborkman@redhat.com>
>> Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
>> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> ---
>>
>> v2) Incorporated Daniel's feedback. I first misinterpreted the feedback
>>     as something not related to pkt_type_offset.
>
> Thanks! It's a nice cleanup.
>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Wait... Isn't there a same patch before?

http://www.spinics.net/lists/netdev/msg294839.html

Maybe not exactly the same, but roughly same from the stats....

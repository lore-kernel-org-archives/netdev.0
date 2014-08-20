From: Cong Wang <cwang@twopensource.com>
Subject: Re: Lost ping responses
Date: Tue, 19 Aug 2014 20:19:52 -0700
Message-ID: <CAHA+R7Pv9HaeNFnOAEr9BHqBRsWKnbeo7R4beOUQe9zyzmKfBA@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1747B1C0@AcuExch.aculab.com>
	<53F331B4.10802@mojatatu.com>
	<063D6719AE5E284EB5DD2968C1650D6D1747B268@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:42982 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbaHTDTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 23:19:54 -0400
Received: by mail-lb0-f177.google.com with SMTP id s7so6053218lbd.8
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 20:19:52 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1747B268@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2014 at 4:35 AM, David Laight <David.Laight@aculab.com> wrote:
> From: Jamal Hadi Salim
>
>> > Any ideas how to find out where the discards are happening?
>> > It might just be somewhere that would affect other traffic flows.
>>
>> netstat -s
>
> Thanks - 'Ip: outgoing packets dropped' increments for every lost response.
>
> Next step is to work out what that means...
>

Try dropwatch, it should give you better hints.

From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [net-next v2] ipv4: inet_bind: check the addr_len first
Date: Wed, 3 Jun 2015 09:56:18 +0300
Message-ID: <CAOJe8K1=xZ03Oo10Oi-U-e2Qz+yJL-zk5Yu1WDy9cOtovbA7iw@mail.gmail.com>
References: <1433247664-7151-1-git-send-email-kda@linux-powerpc.org>
	<1433255612.1164050.284752905.33D64748@webmail.messagingengine.com>
	<CAOJe8K3_Z91o2H9pWFCtSYMoQSbq2Ga0dYFR1Y=MFYGHsGccuA@mail.gmail.com>
	<1433280618.2482044.285146025.2A214C41@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:33082 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbbFCG4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2015 02:56:18 -0400
Received: by ykfr66 with SMTP id r66so431873ykf.0
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 23:56:18 -0700 (PDT)
In-Reply-To: <1433280618.2482044.285146025.2A214C41@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/3/15, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>
>
> On Tue, Jun 2, 2015, at 17:13, Denis Kirjanov wrote:
>> On 6/2/15, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
>> > Hello,
>> >
>> > On Tue, Jun 2, 2015, at 14:21, Denis Kirjanov wrote:
>> >> Perform the address length check first, before calling
>> >> the proto specific bind() function
>> >
>> > Can you give more detail why you did this change and what bug it fixes?
>> I've sent the v2 version with the net-next tag. The idea is simple:
>> check the error condition first and then do the useful work.
>
> Hmm, IMHO the specific proto->bind handlers have to take care of the
> check themselves. You could argue that we should do the checks always in
> inet_bind but then you have to remove the addr_len checks from the raw
> and ping bind handlers, otherwise people become confused if they modify
> the code. I am in favor of leaving the current logic as is, sorry.

Yeah, right, but if we can do the check a bit earlier, why not..

>
> Thanks,
> Hannes
>

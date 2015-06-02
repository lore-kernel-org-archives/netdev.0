From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [net-next v2] ipv4: inet_bind: check the addr_len first
Date: Tue, 2 Jun 2015 18:13:38 +0300
Message-ID: <CAOJe8K3_Z91o2H9pWFCtSYMoQSbq2Ga0dYFR1Y=MFYGHsGccuA@mail.gmail.com>
References: <1433247664-7151-1-git-send-email-kda@linux-powerpc.org>
	<1433255612.1164050.284752905.33D64748@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:34949 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759455AbbFBPNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 11:13:39 -0400
Received: by yhda23 with SMTP id a23so42119898yhd.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 08:13:38 -0700 (PDT)
In-Reply-To: <1433255612.1164050.284752905.33D64748@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/2/15, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> Hello,
>
> On Tue, Jun 2, 2015, at 14:21, Denis Kirjanov wrote:
>> Perform the address length check first, before calling
>> the proto specific bind() function
>
> Can you give more detail why you did this change and what bug it fixes?
I've sent the v2 version with the net-next tag. The idea is simple:
check the error condition first and then do the useful work.

>
> Thanks,
> Hannes
>

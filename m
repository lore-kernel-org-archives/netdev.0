From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: [RFC] UDP SndbufErrors interface and the /proc/net/udp interface.
Date: Tue, 1 Jul 2008 16:50:03 +0300
Message-ID: <d0383f90807010650y1762e0an52b3f8d44a8af33f@mail.gmail.com>
References: <d0383f90806302347q702416faxe29901bf0d2cdbbb@mail.gmail.com>
	 <87wsk5ucu2.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Andi Kleen" <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:10619 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbYGANuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2008 09:50:05 -0400
Received: by fg-out-1718.google.com with SMTP id 19so950672fgg.17
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2008 06:50:04 -0700 (PDT)
In-Reply-To: <87wsk5ucu2.fsf@basil.nowhere.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
>That might be overriden by a very clear use case.


What I had in mind is this:

This can help in debugging problems.

I have a machine which works with many UDP sockets. After some hours
(sometimes days), there are problems ; some of them might be due to
that UDP packets are not sent. I want to know stats per UDP port so
that I will know for each socket how many packets were not sent; in
current implementation, I can only know the total of these packets,
and not per port (by probing into the /proc/net/snmp stats)

Regards,
Ian


On Tue, Jul 1, 2008 at 1:18 PM, Andi Kleen <andi@firstfloor.org> wrote:
> "Ian Brown" <ianbrn@gmail.com> writes:
>>
>> I wonder: would such a patch (form me or others) in needed ? Or will
>> it be rejected because this idea is not good ?
>> In case this idea is not good, I wonder what is the reason for it.
>
> One possible reason against it is that struct sock size is relatively
> critical for memory consumption and there's usually some resistance
> against adding more fields for it.
>
> That might be overriden by a very clear use case.
>
> -Andi
>
>

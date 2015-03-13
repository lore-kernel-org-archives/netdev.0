From: Ronald Pina <pinaronald@gmail.com>
Subject: Re: Allow controlling NAPI weight with sysfs
Date: Fri, 13 Mar 2015 22:37:10 +0100
Message-ID: <CAONBAacG=aMJTp14Yg6u-ZSO-KdCGtEP3gm84BXuYxzCSoVtCw@mail.gmail.com>
References: <CAONBAadmkA6sXA7aJU5_LqFOs1iFzE1WoFW5xgoRfBT3rQKGiw@mail.gmail.com>
	<1426281309.11398.192.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:33488 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757105AbbCMVhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 17:37:11 -0400
Received: by iecvj10 with SMTP id vj10so123870833iec.0
        for <netdev@vger.kernel.org>; Fri, 13 Mar 2015 14:37:10 -0700 (PDT)
In-Reply-To: <1426281309.11398.192.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm going to make a research about the impact of the napi weight
parameter on the network performance. On another scenario the weight
can be use to represent the importance of an interface. Typically it
chosen by the driver depending on the link is uses, but to consider
another case as in dom0 on xen hypervisor, the default weight is 64,
the link is the virtual stack but let consider a case in which we want
that an interface to be given e weight of 32 or 16 and the other use
64 (for example emulating a wan link with weight 16 only for one
interface and the other may use their default).

Controlling napi weight is another supplementary control knob, someone
may found it useful to tweak the performance.
It would be great if we could support  back again changing weight as
the kernel 2.6.12~2.6.21 does.

Thanks

On Fri, Mar 13, 2015 at 10:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-03-13 at 21:49 +0100, Ronald Pina wrote:
>> Hello
>>
>> I am working to allow controlling napi weight on kernel 3.18
>> If may i ask, is it achievable since NAPI interface structure in
>> current kernels is managed by the driver?
>>
>> This feature was presented on kernel 2.6.12, here is a patch that can show
>>  how was that implemented:
>>
>> http://marc.info/?l=linux-netdev&m=111773621018096&w=2
>>
>> As soon as on later kernel the weight was inserted on napi_struct, the
>> weight wasn't exposed any more for every interface wth sysfs.
>>
>> Please, any help or idea is very appreciated.
>
> You did not explain why you would need to tweak weights from sysfs.
>
>
>

From: Michele Dionisio <michele.dionisio@gmail.com>
Subject: Re: [PATCH] ipv6: honour non local bind
Date: Fri, 10 Oct 2014 09:23:28 +0200
Message-ID: <CAFwEtmptxpdshpORv+J3jRMHwsk9HE+bQ7f1B7sWLcOhQa3mSw@mail.gmail.com>
References: <1412867063-28433-1-git-send-email-michele.dionisio@gmail.com>
	<DUB123-W108DA950E52906D29ADEC4EDA00@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>
To: Lukas Tribus <luky-37@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:41839 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751275AbaJJHX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 03:23:29 -0400
Received: by mail-ig0-f172.google.com with SMTP id r2so1668135igi.5
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 00:23:29 -0700 (PDT)
In-Reply-To: <DUB123-W108DA950E52906D29ADEC4EDA00@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have tested the socket option and it is perfectly working but a lot
of software does not use it and the option is linux specific.

Now I have read the previous patch and all the email related. I see
the reason to reject the previous patch, but this one does not add any
new parameter that has to be mantained. It can be usefull to use the
ipv4 parameter also because it is already used if ipv6 is
IPV6_ADDR_MAPPED

regards,

and many thank's for you time to answer me.

2014-10-09 19:07 GMT+02:00 Lukas Tribus <luky-37@hotmail.com>:
> Hi Michele,
>
>
>> I see that net.ipv4.ip_nonlocal_bind = 1 does not works on ipv6 if
>> you try to bind on not local ip.
>> An easy test to see the issue using python is:
>>
>> set net.ipv4.ip_nonlocal_bind = 1 and in python shell try to execute
>>
>> import socket
>> s = socket.socket(family=socket.AF_INET6)
>> s.bind(('2a01:84a0:1001:A001:0000:0:0015:8', 1234))
>>
>> you receive an error. In ipv4 it works.
>>
>> The patch attached solve the issue
>
>
> This has been proposed in the past and refused:
> http://marc.info/?t=132369669000005&r=1&w=2
>
> You will have to set the available socket options from the application.
>
>
>
> Regards,
>
> Lukas
>
>
>

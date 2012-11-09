From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Re: How to compile tcp fast open client app with kernel tfo client
 support ?
Date: Fri, 9 Nov 2012 10:47:01 -0800
Message-ID: <CAK3+h2z5=n6BHGzPjfbrJS4MbVGQ2pdMQP54dOZ8M=8xigUd3Q@mail.gmail.com>
References: <CAK3+h2xmgy+RhUy=MZ5Cu8Zpz+gQmt3dXCX0tpLAWFCTeujBLA@mail.gmail.com>
	<CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:60573 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622Ab2KISrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2012 13:47:01 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so6375022iea.19
        for <netdev@vger.kernel.org>; Fri, 09 Nov 2012 10:47:01 -0800 (PST)
In-Reply-To: <CAGK4HS-U+Ov5x8z+1CRZdiAD9MhfBUfurKKBbt1EWGYFLN8TcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 9, 2012 at 10:23 AM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
>> htmlgettfo.c: In function 'get_page_thread':
>> htmlgettfo.c:109: error: 'MSG_FASTOPEN' undeclared (first use in this function)
>> htmlgettfo.c:109: error: (Each undeclared identifier is reported only once
>> htmlgettfo.c:109: error: for each function it appears in.)
>>
>> I have the 3.6.0 kernel header file package installed
>> /usr/src/linux-headers-3.6.0-custom, the user space include file
>> /usr/include/linux is original one coming with 10.0.4 distro kernel
>>
>> I am suspecting I don't have proper linux header file that has
>> MSG_FASTOPEN declared in user space. can anyone shed a light on how to
>> get MSG_FASTOPEN supported and compiled in client code properly?
>>
>
> Vincent ,
> You can try adding the following to the client code.
>
> #define MSG_FASTOPEN    0x20000000
>
> This is missing still from user space header files I presume.
>
> Vijay

Thanks Vijay, that did it. and the load banlancer doesn't recognize
the option, but traffic pass through ok. the data is sent through the
final ack of 3WHS from linux.

Vincent

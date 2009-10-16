From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Enable syn cookies by default
Date: Fri, 16 Oct 2009 08:55:41 +0000
Message-ID: <20091016085541.GA7393@ff.dom.local>
References: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Olaf van der Spek <olafvdspek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:35525 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757182AbZJPIz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 04:55:57 -0400
Received: by mail-fx0-f218.google.com with SMTP id 18so2132715fxm.37
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 01:55:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <b2cc26e40910150159q68ce555fs4b1683969d939d25@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-10-2009 10:59, Olaf van der Spek wrote:
> On Sat, Oct 10, 2009 at 3:01 PM, Olaf van der Spek <olafvdspek@gmail.com> wrote:
>> Hi,
>>
>> I'm forwarding Debian feature request #520668.
>>
>> Could syn cookies be enabled by default?

Hi,

Alas, I can only give you a hint: while waiting for a better response,
you could try to 'google' for some archives of this list; AFAICR a few
(?) months ago David Miller explained this first question at least.
(In short: they aren't up-to-date enough.)

Regards,
Jarek P.

>>
>> AFAIK syn cookies only get send when the half-open TCP connection
>> queue is full. So stuff like window scaling should work fine in normal
>> situations.
>>
>> Speaking of which:
>> When the half-open TCP connection queue is full and syn cookies are
>> enabled, you get a message like "kernel: possible SYN flooding on port
>> 2710. Sending cookies."
>> However when syn cookies are disabled, you don't get any message (in
>> kern.log), although connections to your server are timing out.
>> Could such a message be added?
>> Maybe with a suggestion to increase the size of that queue or to
>> enable syn cookies.
>>
>> Greetings,
>>
>> Olaf
>>
>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=520668
>> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=520667
>> https://bugs.launchpad.net/ubuntu/+bug/57091
>>
> 
> Somebody?


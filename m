From: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Subject: Re: why usr/include/linux/if_frad.h is required
Date: Wed, 21 Jan 2009 10:20:17 +0530
Message-ID: <3f9a31f40901202050u4b85fef2p8b9848b865c4fda0@mail.gmail.com>
References: <1232463174.3088.15.camel@localhost.localdomain>
	 <1232463242.3088.16.camel@localhost.localdomain>
	 <200901201847.03030.arnd@arndb.de>
	 <m3zlhlycso.fsf@intrepid.localdomain>
	 <1232495335.3123.13.camel@localhost.localdomain>
	 <m3bpu1xyb9.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>,
	Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@elte.hu>,
	Sam Ravnborg <sam@ravnborg.org>, netdev@vger.kernel.org,
	davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:53771 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757208AbZAUEuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 23:50:18 -0500
In-Reply-To: <m3bpu1xyb9.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2009 at 6:36 AM, Krzysztof Halasa <khc@pm.waw.pl> wrote:
> Jaswinder Singh Rajput <jaswinder@kernel.org> writes:
>
>> usr/include/linux/if_frad.h is covered with CONFIG_DLCI from many years
>> and no body is complaining about it so it means no body is using it.
>>
>> So should we need to drop #if / #endif pair or the whole file from
>> userspace.
>
> I think the file. "Empty file exported to userspace", long unused. We
> can also have it back there, and it being not exported is an indicator
> that it's not used. I guess the #ifdef __KERNEL__ can be removed, too.

I will definately define #ifdef __KERNEL__ but I am also curious after
defining it there is no point of making empty
usr/include/linux/if_frad.h

--
JSR

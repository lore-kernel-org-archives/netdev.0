From: Gabor Juhos <juhosg@openwrt.org>
Subject: Re: Driver for embedded switch Micrel KS8995MA
Date: Tue, 13 Dec 2011 20:49:31 +0100
Message-ID: <4EE7AC4B.2070606@openwrt.org>
References: <CAMVnO+n1g1rV_xLhqHONFcSBxJJ6wU3a8vzQ623jZKv0wYnh+A@mail.gmail.com> <CAMVnO+nbtJjyjKXVnQz__A+91cUb6P7VSpkd=f67L1G=rP-dag@mail.gmail.com> <4EE79B78.1040807@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Frederic LAMBERT <frdrc66@gmail.com>, netdev@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:52875 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753601Ab1LMT5I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Dec 2011 14:57:08 -0500
In-Reply-To: <4EE79B78.1040807@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> On 12/13/11 19:33, Frederic LAMBERT wrote:
>> I found an quite old driver on the net for the 5-ports 10/100 embedded
>> switch Micrel KS8995MA.
>> It had to be updated a little bit because a parameter was missing to
>> the ks8995_registers_read()&  write() functions.
>>
>> I haven't been able to contact its original author, Gabor Juhos, who
>> wrote it in 2008 under GPL v2.

Sorry, I did not see your e-mail. It has been marked as spam by one of my mail
filters.

> Gabor is responding pretty quickly in general. You are talking about this
> particular driver?
> 
> https://dev.openwrt.org/browser/trunk/package/spi-ks8995/src/spi_ks8995.c
> 
>>
>> Is it possible to submit this driver as a patch to be included in the
>> distribution?

The driver was used for an IXP4xx based board originally. I have bricked my
board a long time ago, so I can't test the driver anymore. If you can use the
driver for anything, feel free to send that upstream.

-Gabor

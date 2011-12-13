From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Driver for embedded switch Micrel KS8995MA
Date: Tue, 13 Dec 2011 19:37:44 +0100
Message-ID: <4EE79B78.1040807@openwrt.org>
References: <CAMVnO+n1g1rV_xLhqHONFcSBxJJ6wU3a8vzQ623jZKv0wYnh+A@mail.gmail.com> <CAMVnO+nbtJjyjKXVnQz__A+91cUb6P7VSpkd=f67L1G=rP-dag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, juhosg@openwrt.org
To: Frederic LAMBERT <frdrc66@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55971 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab1LMSid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 13:38:33 -0500
Received: by eaaj10 with SMTP id j10so1377170eaa.19
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2011 10:38:32 -0800 (PST)
In-Reply-To: <CAMVnO+nbtJjyjKXVnQz__A+91cUb6P7VSpkd=f67L1G=rP-dag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 12/13/11 19:33, Frederic LAMBERT wrote:
> I found an quite old driver on the net for the 5-ports 10/100 embedded
> switch Micrel KS8995MA.
> It had to be updated a little bit because a parameter was missing to
> the ks8995_registers_read()&  write() functions.
>
> I haven't been able to contact its original author, Gabor Juhos, who
> wrote it in 2008 under GPL v2.

Gabor is responding pretty quickly in general. You are talking about 
this particular driver?

https://dev.openwrt.org/browser/trunk/package/spi-ks8995/src/spi_ks8995.c

>
> Is it possible to submit this driver as a patch to be included in the
> distribution?
> If yes, what would be the best place? driver/net/phy? driver/net/ethernet?

drivers/net/phy is the most appropriate place since it's a switch driver 
but you certainly want to get in touch with Gabor to deal with this 
driver inclusion first.
--
Florian

From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: inetpeer with create==0
Date: Thu, 3 Mar 2011 16:07:32 +0800
Message-ID: <AANLkTinz4ppTi=580K9O=RZ6zbuBrTtjBDhEEnWM3Txg@mail.gmail.com>
References: <AANLkTimwaUaC7Xu2djSNR9k98sYbSM0V88sCAc34R6Ac@mail.gmail.com>
 <20110302.213634.189680857.davem@davemloft.net> <AANLkTi=Ty+C3b9U+151dUMpgGiwG3AE4dMmc3djWmp6v@mail.gmail.com>
 <20110302.224220.179921025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42934 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab1CCIHx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 03:07:53 -0500
Received: by fxm17 with SMTP id 17so844099fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 00:07:52 -0800 (PST)
In-Reply-To: <20110302.224220.179921025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 3, 2011 at 2:42 PM, David Miller <davem@davemloft.net> wrot=
e:
>
> Thats why I am working hard to remove it :-)
>
> The %99 percentile performance of our routing cache is absolutely
> terrible. =A0The routing cache does nothing except get in the way.
>
> It is the reason why Linux is still completely unsuitable for use as =
a
> router on the core internet.
>

After routing cache is removed totally, Linux is still unsuitable for
use as a router on the core internet. Because it isn't a realtime OS,
and the forwarding delay isn't bounded. With routing cache, the memory
cost isn't bounded too. :)

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)

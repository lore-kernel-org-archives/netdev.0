From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: Re: [PATCH 1/5] tg3: use usleep_range not msleep for small sleeps
Date: Thu, 3 Mar 2011 13:14:34 +0100
Message-ID: <AANLkTi=2SdwC6BbsPVTwXQ7M3zif=P-oO0UcHdHM5S=c@mail.gmail.com>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
 <1298999069-12740-2-git-send-email-martinez.javier@gmail.com> <20110302.205536.226759949.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mcarlson@broadcom.com, mchan@broadcom.com,
	grant.likely@secretlab.ca, netdev@vger.kernel.org,
	kernelnewbies@kernelnewbies.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38400 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754676Ab1CCMOu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 07:14:50 -0500
Received: by wyg36 with SMTP id 36so965842wyg.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 04:14:49 -0800 (PST)
In-Reply-To: <20110302.205536.226759949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>>
>> Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
>
> Why?
>

As I understand msleep() will stop for a minimum of two jiffies and
that resolution is too low in systems with small HZ values (big
jiffies).
Using msleep() (with small values) in this systems will sleep for more
time than the caller expects.

I used usleep_range() because it is a finer precision implementations o=
f msleep.

Sorry if I'm wrong or the sleep precision is not a concern in this
driver and the change doesn't add any value.

Thanks a lot.

--=20
-----------------------------------------
Javier Mart=C3=ADnez Canillas
(+34) 682 39 81 69
PhD Student in High Performance Computing
Computer Architecture and Operating System Department (CAOS)
Universitat Aut=C3=B2noma de Barcelona
Barcelona, Spain

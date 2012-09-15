From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: Re: Remarks and comments about ipconfig behavior
Date: Sat, 15 Sep 2012 18:18:24 +0200
Message-ID: <5054AA50.70108@gmail.com>
References: <5052403B.4040408@gmail.com> <20120913.163134.361379133013906511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:60947 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126Ab2IOQSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 12:18:32 -0400
Received: by eekc1 with SMTP id c1so2908987eek.19
        for <netdev@vger.kernel.org>; Sat, 15 Sep 2012 09:18:31 -0700 (PDT)
In-Reply-To: <20120913.163134.361379133013906511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/09/2012 22:31, David Miller a =E9crit :
> I've seen PHY/switch/hub combinations that take longer than 30 second=
s to fully negotiate the link. There is really no upper limit to the li=
nk speed/duplex/etc. negoatiation process. Even if the actual negoatiat=
ion protocol had an upper limit on negoatiation time, hardware implemen=
tations do things like try sampling the quality of the cable signal and=
 may choose to down-rev the advertised features and restart the negoati=
ation.=20

I do understand that some might need some longer values while some othe=
rs like me really need a smaller one.

On my case, this 2mn wait breaks an hardware watchdog, so I did a small=
 patch on my local build to get it reduced as I know  the selected valu=
e works fine for this hardware setup. And it works now perfectly.

So could it be valuable to export it as a CONFIG_something instead of p=
atching this #define ?

Cheers,

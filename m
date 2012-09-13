From: Erwan Velu <erwanaliasr1@gmail.com>
Subject: Re: Remarks and comments about ipconfig behavior
Date: Thu, 13 Sep 2012 22:37:45 +0200
Message-ID: <50524419.4080404@gmail.com>
References: <5052403B.4040408@gmail.com> <20120913.163134.361379133013906511.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41854 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab2IMUh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:37:56 -0400
Received: by eekc1 with SMTP id c1so2168976eek.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 13:37:54 -0700 (PDT)
In-Reply-To: <20120913.163134.361379133013906511.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 13/09/2012 22:31, David Miller a =E9crit :
> From: Erwan Velu<erwanaliasr1@gmail.com>
> Date: Thu, 13 Sep 2012 22:21:15 +0200
>
>> That lever for me two points :
>> - why is this timeout setup for so long ? Even with a spantree
>> - configuration, not having a carrier for 2mn is *waow* ... Does a 3=
0sec
>> - could not be enough ? What is the need of waiting so long time ?
> I've seen PHY/switch/hub combinations that take longer than 30 second=
s
> to fully negotiate the link.
>
> There is really no upper limit to the link speed/duplex/etc.
> negoatiation process.
>
> Even if the actual negoatiation protocol had an upper limit on
> negoatiation time, hardware implementations do things like try
> sampling the quality of the cable signal and may choose to
> down-rev the advertised features and restart the negoatiation.
Ok but shouldn't we display some message to the user trying to explain=20
why the kernel is stopped and perfectly silent during its booting=20
process ? 2 minutes, that's a pretty long time with an almost frozen=20
kernel isn't it ?

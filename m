From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 19:03:55 +0100
Message-ID: <298f5c050905181103g3365ddd0g8d398c258c4df382@mail.gmail.com>
References: <298f5c050905150745p13dc226eia1ff50ffa8c4b300@mail.gmail.com>
	 <298f5c050905150749s3597328dr8dd15adbd7a37532@mail.gmail.com>
	 <20090515111227.7fc758cd@nehalam>
	 <298f5c050905180301s1c4ffdb2p61a155668eb39bd2@mail.gmail.com>
	 <20090518091314.06bf60d2@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net,
	davem@davemloft.net, devik@cdi.cz
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:60601 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbZERSDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 14:03:55 -0400
Received: by fxm2 with SMTP id 2so3397966fxm.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 11:03:56 -0700 (PDT)
In-Reply-To: <20090518091314.06bf60d2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have my kernel's timer frequency set to 1000Hz since the beginning.
I've got all these results with HZ_1000.

(I'm working on clocksource)

Thanks
  Antonio Almeida


On Mon, May 18, 2009 at 5:13 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Mon, 18 May 2009 11:01:21 +0100
> Antonio Almeida <vexwek@gmail.com> wrote:
>
>> Hi!
>>
>> cat /sys/devices/system/clocksource/clocksource0/current_clocksource
>> returns "jiffies"
>
> That is the slowest of the choices. Better ones are hpet and tsc, but you
> hardware doesn't support them.
>
> You should compile your kernel with HZ=1000 and the resolution will be better
> (but with some loss of performance).
>

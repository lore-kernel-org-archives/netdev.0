From: Jerry Chu <hkchu@google.com>
Subject: Re: [PATCH] Add useful per-connection TCP stats for diagnosis purpose.
Date: Fri, 18 Mar 2011 22:38:52 -0700
Message-ID: <AANLkTimsoF+khCfU2aEQNoJ0DBf_p9-v+Zim0X5RrLpw@mail.gmail.com>
References: <1300349189-2731-1-git-send-email-hkchu@google.com>
	<1300351330.10164.712.camel@edumazet-laptop>
	<AANLkTi=sLkXreC3LNsDuFDSeNMebr+ScMc12=gngd2cc@mail.gmail.com>
	<20110317142030.62af785a@nehalam>
	<AANLkTi=W-=8zhQpfJZ=DrDyUCwrT==5JkwRBiHaDkVXK@mail.gmail.com>
	<1300428324.2881.5.camel@edumazet-laptop>
	<AANLkTikrJ7A-ygc9JnkvfBpRaKjL0fKeta+9ASLDr0rg@mail.gmail.com>
	<1300510960.2831.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21515 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280Ab1CSFiy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 01:38:54 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p2J5cr9J014003
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 22:38:54 -0700
Received: from ywa1 (ywa1.prod.google.com [10.192.1.1])
	by kpbe17.cbf.corp.google.com with ESMTP id p2J5cqaE019575
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 22:38:52 -0700
Received: by ywa1 with SMTP id 1so2201936ywa.39
        for <netdev@vger.kernel.org>; Fri, 18 Mar 2011 22:38:52 -0700 (PDT)
In-Reply-To: <1300510960.2831.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 18, 2011 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le vendredi 18 mars 2011 =E0 21:33 -0700, Jerry Chu a =E9crit :
>
>> I'm well aware of the past, hideous O(n**2) problem of reading
>> /proc/net/tcp but I
>> thought the problem has been fixed by Tom Herbert a while back, no?
>> (See http://marc.info/?l=3Dlinux-netdev&m=3D127588123429437&w=3D2)
>>
>
> O(N) is still too slow, to gather stats for your socket, if you want =
to
> gather stats once per second for example.

I don't see anyway around O(n). The netlink/inet_diag_dump() will take =
at
best O(n) too.

>
> AFAIK, I am not sure we want to allow any user to access all these da=
ta
> for all tcp sockets on the machine. This might have security impacts.

This seems to be an orthogonal issue to netlink or /proc/net/tcp.

Jerry

>
>
>
>

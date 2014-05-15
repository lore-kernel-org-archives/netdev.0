From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: Ethernet bug at Upstream-v3.15-rcx on Lager.
Date: Thu, 15 May 2014 21:20:19 +0400
Message-ID: <5374F753.70203@cogentembedded.com>
References: <53745E88.7040108@jinso.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Simon Horman <horms@verge.net.au>
To: cm-hiep@jinso.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:58410 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605AbaEORUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 13:20:17 -0400
Received: by mail-lb0-f173.google.com with SMTP id 10so1056339lbg.32
        for <netdev@vger.kernel.org>; Thu, 15 May 2014 10:20:15 -0700 (PDT)
In-Reply-To: <53745E88.7040108@jinso.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 05/15/2014 10:28 AM, =E3=82=AB=E3=82=AA=E3=80=80=E3=83=9F=E3=83=B3=E3=
=80=80=E3=83=92=E3=82=A7=E3=83=83=E3=83=97 wrote:

> I am Hiep from JINZAI SOLUTION (a Japanese Company).
> Now, I am testing a upstream-v3.15-rc2 on Lager for Renesas RSO.
> I found a problem about Ethernet Driver so I would like to report to =
you.
> The problem is losing data when sending data by UDP:

>      - From Lager board to PC:
>      BANDWIDTH from 10M to 70M are good,  but they suddenly  down 51.=
2
> Mbits/sec at 80M
>      and 57.8 Mbits/sec at 90 M and 64.2 Mbits/sec at 100M.

    Do you mean 'iperf' tests here?

>      - From PC to Lager board:
>     Some time when the message of "sh-eth r8a7790-ether eth0: Receive=
 FIFO
> Overflow" occurs,
>     some of datagrams will be lost as the logs show below:
>      =E3=80=8C$ iperf -c 172.16.1.36 -u -b 90M
>      .....
>      [  3] Server Report:
>      [  3]  0.0-10.0 sec   108 MBytes  90.4 Mbits/sec   0.000 ms 36/7=
6923
> (0.047%)
>      .....
>      # iperf -s -u
>      [ ID] Interval       Transfer     Bandwidth        Jitter Lost/T=
otal
> Datagrams
>      sh-eth r8a7790-ether eth0: Receive FIFO Overflow
>      [  3]  0.0-10.0 sec   108 MBytes  90.4 Mbits/sec   0.001 ms 36/7=
6923
> (0.047%)

> Please review it when you have time.

    Please try this patch:

http://marc.info/?l=3Dlinux-netdev&m=3D139602519809181

> Bests Regards,
> Cao Minh Hiep.

WBR, Sergei

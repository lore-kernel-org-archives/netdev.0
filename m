From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [iproute2] tc: Show classes more hierarchically]
Date: Tue, 16 Dec 2014 05:49:02 -0800
Message-ID: <1418737742.9773.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141215224851.GB6734@angus-think.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vadim4j@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:64634 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbaLPNtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 08:49:05 -0500
Received: by mail-ie0-f177.google.com with SMTP id rd18so12295375iec.8
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 05:49:04 -0800 (PST)
In-Reply-To: <20141215224851.GB6734@angus-think.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-16 at 00:48 +0200, vadim4j@gmail.com wrote:
> Hi All,
> 
> I am playing with showing classes in more hierarchically format and I
> have some code and example of output from my TC looks like:
> 
> # tc/tc -t class show dev tap0
> 
>  \---1:2 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>         \---1:40 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>         \---1:50 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>         \---1:60 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>  \---1:1 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>         \---1:10 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>                \---1:11 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>                       \---1:111 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>         \---1:20 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
>         \---1:30 (htb) prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b 
> 
> 

> So I'd like to ask if it might be useful for the TC users (may be
> better format ?) to have this ?

Sure, this seems interesting, thanks !

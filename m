From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: NAPI: Polling function requesting extra calls - difference
 between 3.18.11 and 4.0.0
Date: Thu, 23 Apr 2015 21:08:37 +0200
Message-ID: <CACna6rzx0=P5dOYggLCihg+9ONKfL428PYhP8CQrTgtKG5N_PQ@mail.gmail.com>
References: <CACna6rzMMUA_MQemYyP93+TjP4aocL1WaYQUJFwQm3+DLNAefg@mail.gmail.com>
	<1429813732.22254.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38204 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030479AbbDWTIi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 15:08:38 -0400
Received: by igbhj9 with SMTP id hj9so32541352igb.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 12:08:37 -0700 (PDT)
In-Reply-To: <1429813732.22254.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23 April 2015 at 20:28, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2015-04-23 at 20:18 +0200, Rafa=C5=82 Mi=C5=82ecki wrote:
>
>>
>> Can you help us with this, please? Does bgmac use NAPI incorrectly?
>> Were there some important changes in 3.19 or 4.0?
>>
>
> Right they were important changes in NAPI indeed :
>
> 3b47d30396ba net: gro: add a per device gro flush timer
> d75b1ade567f net: less interrupt masking in NAPI
> bc9ad166e38a net: introduce napi_schedule_irqoff()

As you obviously noticed, I fixed bgmac now and submitted the fix.

Just wanted to say a thanks for helping with that!

--=20
Rafa=C5=82

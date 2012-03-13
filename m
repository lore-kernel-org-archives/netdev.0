From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: pfifo_fast - use ffs(x)-1 instead of array lookup
Date: Tue, 13 Mar 2012 00:23:27 -0700
Message-ID: <CAHo-OoyWH9v+D7yJp3sAKnmUEp_DiTeDhmgPme2dGoqWGa2qjg@mail.gmail.com>
References: <1331615541-18214-1-git-send-email-zenczykowski@gmail.com>
	<20120312.225435.1585479447873313061.davem@davemloft.net>
	<CAHo-Ooyi_NOZeT978EjUaPSYBMco9FmQh8uNpCLr-6owfYyMTQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55782 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab2CMHX2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 03:23:28 -0400
Received: by wibhj6 with SMTP id hj6so4922569wib.1
        for <netdev@vger.kernel.org>; Tue, 13 Mar 2012 00:23:27 -0700 (PDT)
In-Reply-To: <CAHo-Ooyi_NOZeT978EjUaPSYBMco9FmQh8uNpCLr-6owfYyMTQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was actually leaning towards going with ffs()-1, since

it's excellent on x86-64
good on x86_cmov
decent on x86
good on armv5+

and I'm guessing it'll be good or better on any modern platform

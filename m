From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression: TCP connections fail over wireless: bad cksum?
Date: Thu, 04 Sep 2014 16:38:29 -0700
Message-ID: <1409873909.26422.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5408C788.4050401@tedp.id.au>
	 <1409871007.26422.125.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5408F3FB.2010107@tedp.id.au>
	 <1409873287.26422.127.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ted Percival <ted@tedp.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:61169 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175AbaIDXia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 19:38:30 -0400
Received: by mail-pa0-f43.google.com with SMTP id et14so21117272pad.30
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 16:38:30 -0700 (PDT)
In-Reply-To: <1409873287.26422.127.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 16:28 -0700, Eric Dumazet wrote:

> tc -s -d qd show dev wlan0
> 
> tc qdisc replace dev wlan0 fq

I forgot the root keyword :

tc qdisc replace dev wlan0 root fq

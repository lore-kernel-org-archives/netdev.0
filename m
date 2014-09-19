From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: cannot ARP macvlan on top of bonding device
Date: Fri, 19 Sep 2014 14:47:28 -0700
Message-ID: <1411163248.26859.41.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140919210040.E09BA481010@fruggeri-Arora18.sjc.aristanetworks.com>
	 <1411161451.26859.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+HUmGi16QV2r7BuJYQWBckUG=oCe04JwJQFAyj=LihL=Rj5Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Francesco Ruggeri <fruggeri@aristanetworks.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, nicolas.dichtel@6wind.com
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33155 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932200AbaISVra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:47:30 -0400
Received: by mail-pa0-f42.google.com with SMTP id et14so880848pad.29
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:47:30 -0700 (PDT)
In-Reply-To: <CA+HUmGi16QV2r7BuJYQWBckUG=oCe04JwJQFAyj=LihL=Rj5Kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 14:35 -0700, Francesco Ruggeri wrote:

> 
> After sending my email I noticed that Nicolas Dichtel already
> submitted a similar patch at
> http://marc.info/?l=linux-netdev&m=141094132726614&w=2

Yes, this all sounded familiar ;)

We yet have to address the race condition.

Herbert maybe ?

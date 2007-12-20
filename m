From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [IPROUTE]: A workaround to make larger rto_min printed
 correctly
Date: Thu, 20 Dec 2007 21:24:42 +0100
Message-ID: <476ACF8A.7060201@gmail.com>
References: <d72b7ace0712191931w37f02645u8d5eb5eef9c1fba4@mail.gmail.com>	 <20071220091230.GB1924@ff.dom.local> <d72b7ace0712200821k7cde0834rf1187b30c68cd1ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Satoru SATOH <satoru.satoh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:51988 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbXLTUW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 15:22:26 -0500
Received: by nf-out-0910.google.com with SMTP id g13so8433nfb.21
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 12:22:25 -0800 (PST)
In-Reply-To: <d72b7ace0712200821k7cde0834rf1187b30c68cd1ce@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Satoru SATOH wrote, On 12/20/2007 05:21 PM:

> i see. HZ can be < 1000.. i should be wrong.
> 
> however, i got the following,
> 
> [root iproute2.org]# ./ip/ip route change 192.168.140.0/24 dev eth1 rto_min 4s
> [root iproute2.org]# gdb -q ./ip/ip 

...

> (gdb) p hz
> $1 = 1000000000

That's why I had some doubts! I didn't study this enough, but my
(older) version definitely showed hz == 100. Maybe I'm wrong, but
looking into lib/util.c it seems this could be set differently
depending on system's configuration (or even kernel version).

So, probably this patch could sometimes work even for HZ < 1000,
but since it's your patch, I hope you do some additional checking
if it's always like this...

Cheers,
Jarek P.

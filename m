From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 21:05:41 +0200
Message-ID: <20090518190541.GA3047@ami.dom.local>
References: <20090517201528.GA8552@ami.dom.local> <20090518065629.GA6006@ff.dom.local> <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com> <20090518175352.GB2755@ami.dom.local> <298f5c050905181123o55c35e74n24cd4ee2c07d8fca@mail.gmail.com> <20090518183221.GC2755@ami.dom.local> <298f5c050905181156w2254fcb4p889d67e26fad6e6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>
To: Antonio Almeida <vexwek@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f174.google.com ([209.85.218.174]:64023 "EHLO
	mail-bw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbZERTHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 15:07:45 -0400
Received: by bwz22 with SMTP id 22so3396781bwz.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 12:07:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <298f5c050905181156w2254fcb4p889d67e26fad6e6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 18, 2009 at 07:56:12PM +0100, Antonio Almeida wrote:
> Precise measurements:
> 
> 800 bytes:
> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
> 70901b/8 mpu 0b overhead 0b level 0
>  Sent 46793626324 bytes 57771194 pkt (dropped 29920019, overlimits 0 requeues 0)
>  rate 621714Kbit 97631pps backlog 0b 126p requeues 0
>  lended: 57771068 borrowed: 0 giants: 0
>  tokens: -8 ctokens: -8
> 
> 
> 850 bytes:
> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
> 70901b/8 mpu 0b overhead 0b level 0
>  Sent 63422144616 bytes 77714246 pkt (dropped 41012275, overlimits 0 requeues 0)
>  rate 600699Kbit 88756pps backlog 0b 127p requeues 0
>  lended: 77714119 borrowed: 0 giants: 0
>  tokens: -11 ctokens: -11
> 
> 
> 900 bytes:
> class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
> 555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
> 70901b/8 mpu 0b overhead 0b level 0
>  Sent 76868403562 bytes 92835297 pkt (dropped 48565133, overlimits 0 requeues 0)
>  rate 636195Kbit 88755pps backlog 0b 126p requeues 0
>  lended: 92835171 borrowed: 0 giants: 0
>  tokens: -7 ctokens: -7
> 
> 
> If you need more values you're free to ask.

Since you're so kind... :-) There is a line in net/sched/sch_htb.c:

#define HTB_HYSTERESIS 1        /* whether to use mode hysteresis for speedup */

Could you change 1 to 0, and repeat these tests above after recompiling?

More thanks,
Jarek P.

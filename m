From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Mon, 18 May 2009 19:56:12 +0100
Message-ID: <298f5c050905181156w2254fcb4p889d67e26fad6e6@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <20090518065629.GA6006@ff.dom.local>
	 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	 <20090518175352.GB2755@ami.dom.local>
	 <298f5c050905181123o55c35e74n24cd4ee2c07d8fca@mail.gmail.com>
	 <20090518183221.GC2755@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:53900 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbZERS4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 14:56:12 -0400
Received: by fxm2 with SMTP id 2so3426221fxm.37
        for <netdev@vger.kernel.org>; Mon, 18 May 2009 11:56:12 -0700 (PDT)
In-Reply-To: <20090518183221.GC2755@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Precise measurements:

800 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 46793626324 bytes 57771194 pkt (dropped 29920019, overlimits 0 requeues 0)
 rate 621714Kbit 97631pps backlog 0b 126p requeues 0
 lended: 57771068 borrowed: 0 giants: 0
 tokens: -8 ctokens: -8


850 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 63422144616 bytes 77714246 pkt (dropped 41012275, overlimits 0 requeues 0)
 rate 600699Kbit 88756pps backlog 0b 127p requeues 0
 lended: 77714119 borrowed: 0 giants: 0
 tokens: -11 ctokens: -11


900 bytes:
class htb 1:108 parent 1:10 leaf 108: prio 7 quantum 1514 rate
555000Kbit ceil 555000Kbit burst 70901b/8 mpu 0b overhead 0b cburst
70901b/8 mpu 0b overhead 0b level 0
 Sent 76868403562 bytes 92835297 pkt (dropped 48565133, overlimits 0 requeues 0)
 rate 636195Kbit 88755pps backlog 0b 126p requeues 0
 lended: 92835171 borrowed: 0 giants: 0
 tokens: -7 ctokens: -7


If you need more values you're free to ask.

  Antonio Almeida


On Mon, May 18, 2009 at 7:32 PM, Jarek Poplawski <jarkao2@gmail.com> wrote:
> On Mon, May 18, 2009 at 07:23:14PM +0100, Antonio Almeida wrote:
>> Here's my .config
>
> Hmm... And if it's not a big problem I'd also ask you to try this test
> with 555000Kbit rate for 850 and 900 byte packets. (It can wait.)
>
> Thanks again,
> Jarek P.
>

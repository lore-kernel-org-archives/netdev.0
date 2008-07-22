From: "Markus Werner" <markiwer@googlemail.com>
Subject: Re: Invalid truesize messages since 2.6.25
Date: Tue, 22 Jul 2008 19:20:48 +0200
Message-ID: <8a75de9b0807221020s6831bebahafa4de57e93d3098@mail.gmail.com>
References: <3C59DB883F7B0B4D8096010D45ACCD13C73AFA@exch.facton.local>
	 <20080722114311.GQ10471@solarflare.com>
	 <3C59DB883F7B0B4D8096010D45ACCD13C73B02@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ben Hutchings" <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:27602 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843AbYGVRUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 13:20:52 -0400
Received: by py-out-1112.google.com with SMTP id p76so1423607pyb.10
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 10:20:49 -0700 (PDT)
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13C73B02@exch.facton.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/7/22 Beschorner Daniel <Daniel.Beschorner@facton.com>:
>>> Since 2.6.25 we rarely see these messages:
>>>
>>> SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216

Same problem here.

>>> Yesterday I saw it the first time after a runtime of one week with
>>> 2.6.26.
>>> The box is web server / IPSEC gateway.
>>> Obviously nothing seems to be affected by the message but <= 2.6.24
> no
>>> messages appeared.
>
>> Invalid truesize can be caused by bugs in many different places.  So
> it
>> might be helpful to say which driver(s) and any unusual network
> protocol
>> or filter you are using.
>
> Network driver: tg3
> IPSEC: esp tunnels, ipcomp, 3des/aes
> I use this config so far on other servers too without this message.

Kernel: 2.6.26
Tested drivers: pcnet32, e1000, vmxnet

> The unusal part special to this server may be:
> Bandwidth management via htb & sfq, CONFIG_IP_MULTIPLE_TABLES for source
> IP routing

Both are used here too, but no IPSec.

This box is a router to the internet and an openvpn gateway. The
problem is not reliably reproducible, but it seems to happen when the
box is routing udp traffic, for example heavy openvpn usage or video
streaming via udp.


Markus

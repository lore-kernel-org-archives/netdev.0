From: "ZioPRoTo (Saverio Proto)" <zioproto@gmail.com>
Subject: Re: IP/UDP encapsulation
Date: Thu, 8 Apr 2010 12:39:24 +0200
Message-ID: <l2ka5e23ab91004080339mf2ac0b2bq2d02fb1c8d1def09@mail.gmail.com>
References: <20100408074247.GA19798@vigoh>
	 <20100408191831.08cd8d7b@opy.nosense.org>
	 <1270722573.2215.47.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	"Gustavo F. Padovan" <gustavo@padovan.org>,
	netdev <netdev@vger.kernel.org>,
	marco bonola <marco.bonola@gmail.com>,
	Behling Mario <mb@mariobehling.de>,
	"L. Aaron Kaplan" <aaron@lo-res.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f191.google.com ([209.85.210.191]:59154 "EHLO
	mail-yx0-f191.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab0DHKjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 06:39:25 -0400
Received: by yxe29 with SMTP id 29so553197yxe.4
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 03:39:25 -0700 (PDT)
In-Reply-To: <1270722573.2215.47.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I'm a bit confused. How can tunnelling IP in UDP in IP be faster than IP in IP?
>>
>
> Maybe the 'gateway' doesnt handle IPIP at all ;)

Yes that's the point. IP in UDP is more supported. It has much an
easier way when your traffic travels over the Internet, and maybe you
have to pass some NAT. Some NAT will not handle at all IP in IP
packets.

IP in IP has of course less overhead but you can experience problems
and many network setups. This is why at Freifunk we are thinking of
developing this kernel module.

Regards

Saverio Proto

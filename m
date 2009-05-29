From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC
	interrupt may not be shared
Date: Fri, 29 May 2009 07:45:05 -0400
Message-ID: <8bd0f97a0905290445x3b0829f3h657fec534f290c7f@mail.gmail.com>
References: <8A42379416420646B9BFAC9682273B6D0B43DCCD@limkexm3.ad.analog.com>
	 <20090529.041435.163819214.davem@davemloft.net>
	 <8bd0f97a0905290422x502d6006yb05ebe231b05e9bc@mail.gmail.com>
	 <20090529.042817.176293351.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:32554 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757886AbZE2LpE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:45:04 -0400
Received: by yx-out-2324.google.com with SMTP id 3so3301168yxj.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 04:45:05 -0700 (PDT)
In-Reply-To: <20090529.042817.176293351.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 07:28, David Miller wrote:
> From: Mike Frysinger <vapier.adi@gmail.com>
>> why implement extra over head in an interrupt handler to support an
>> operating mode the hardware can never support.
>
> What overhead? =C2=A0It should be pretty easy to see if the device
> is really indicating an interrupt or not :-)

which would involve reading system mmrs which are clocked at the
system frequency and thus make the core stall
-mike

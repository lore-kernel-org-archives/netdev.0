From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] b43: Increase number of RX DMA slots
Date: Tue, 19 Feb 2013 20:42:02 -0600
Message-ID: <512437FA.2030105@lwfinger.net>
References: <20130219.005206.397289032011003833.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7152@saturn3.aculab.com> <5123BCFF.5090408@lwfinger.net> <20130219.131553.787630407148880340.davem@davemloft.net> <5123C43D.2020602@lwfinger.net> <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, David.Laight@aculab.com,
	linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, bittorf@bluebottle.com,
	stable@vger.kernel.org
To: Julian Calaby <julian.calaby@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:39261 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934588Ab3BTCmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 21:42:08 -0500
In-Reply-To: <CAGRGNgWZ0qUJSSkjmP8o4VaPRBdN67J=RPy5+45rWaQQXWnWrQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 06:47 PM, Julian Calaby wrote:
>
> Is it be possible to increase the number of slots at runtime? Maybe an
> even better solution would be to keep the existing number of slots,
> and if they run out, reset and increase incrementally to some sensible
> maximum value.

The number could be increased a bit, but on systems with 32-bit DMA such as the 
BCM4318, the maximum size of the ring buffer is 4KB. Even more importantly, each 
slot is allocated an skb of 2390 bytes. Even at 256 slots, the memory allocation 
is pretty large.

Larry

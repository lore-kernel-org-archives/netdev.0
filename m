From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RESEND PATCH net-next v2 3/3] net: bcmgenet: cleanup for dmadesc_set()
Date: Tue, 5 Apr 2016 16:20:56 -0700
Message-ID: <CAGVrzcbMZxmWg=TWHBH7fMe4EX7dngkBxbjuCKp=J2ZxcdmLVg@mail.gmail.com>
References: <1459890001-78171-1-git-send-email-pgynther@google.com> <1459890001-78171-4-git-send-email-pgynther@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:35816 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbcDEXVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 19:21:37 -0400
Received: by mail-ig0-f194.google.com with SMTP id ya17so4788314igc.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 16:21:36 -0700 (PDT)
In-Reply-To: <1459890001-78171-4-git-send-email-pgynther@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-04-05 14:00 GMT-07:00 Petri Gynther <pgynther@google.com>:
> dmadesc_set() is used for setting the Tx buffer DMA address, length,
> and status bits on a Tx ring descriptor when a frame is being Tx'ed.
>
> Always set the Tx buffer DMA address first, before updating the length
> and status bits, i.e. giving the Tx descriptor to the hardware.
>
> The reason this is a cleanup rather than a fix is that the hardware
> won't transmit anything from a Tx ring until the TDMA producer index
> has been incremented. As long as the dmadesc_set() writes complete
> before the TDMA producer index write, life is good.
>
> Signed-off-by: Petri Gynther <pgynther@google.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

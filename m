From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCHv3] net: Define enum for the bits used in features.
Date: Thu, 26 May 2011 12:40:50 +0200
Message-ID: <BANLkTik5aF-CafhXSuTOZdCZuJiyz_Ot_A@mail.gmail.com>
References: <1306288567-1773-1-git-send-email-maheshb@google.com> <1306363336-13614-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:61904 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab1EZKlL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 06:41:11 -0400
Received: by qyg14 with SMTP id 14so300359qyg.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 03:41:10 -0700 (PDT)
In-Reply-To: <1306363336-13614-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/26 Mahesh Bandewar <maheshb@google.com>:
> Little bit cleanup by defining enum for all bits used. Also use those=
 enum
> values to redefine flags.
[...]

This BIT2FLAG macro just obfuscates the code (and gives you more
characters to read).

I'd also prefer this patch included the GSO/TSO bits and they are
logically part of this cleanup. But if you think it's easier to review
split, then that's fine by me.

Best Regards,
Micha=C5=82 Miros=C5=82aw

From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net-netlink: Add a new attribute to expose TCLASS values
 via netlink
Date: Mon, 7 Nov 2011 16:29:06 -0800
Message-ID: <CANP3RGftp4992SgoqW04tZwCuo4_mQcJ26qr=Op30rkyt5NWOw@mail.gmail.com>
References: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
	<20111107162704.0b569074@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Murali Raja <muralira@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57963 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab1KHA3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:29:08 -0500
Received: by ggnb2 with SMTP id b2so5846336ggn.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 16:29:07 -0800 (PST)
In-Reply-To: <20111107162704.0b569074@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Do we really want to continue to expose that as a supported
> API. I would argue it was a mistake in the original implementation.

Yes, that's an interesting question...

However, can this be changed at this point in time?

Theoretically network fabric hardware could interpret v4 and v6 dscp
code points differently
(don't think anyone sane would do really want to do this though...)

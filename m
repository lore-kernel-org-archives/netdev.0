From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 13:14:44 -0700
Message-ID: <CANP3RGc1+n3Qt7k53NJtPO9njZw+WNVLKTLJq=ErYJmyb-Skcg@mail.gmail.com>
References: <20130321.114616.279859400813363663.davem@davemloft.net>
	<1363882091.4431.20.camel@edumazet-glaptop>
	<CAM8tLiMbSQZZW0NBPXGgdHRSJ8UqH+q=QaR+2KOqsf-gt6RHGg@mail.gmail.com>
	<20130321.145627.565133121162775865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Kravkov <dkravkov@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Hsiao-keng Jerry Chu <hkchu@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:65139 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab3CUUOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 16:14:44 -0400
Received: by mail-oa0-f45.google.com with SMTP id o6so3633031oag.32
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 13:14:44 -0700 (PDT)
In-Reply-To: <20130321.145627.565133121162775865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reverting/deleting this code is going way too far.
Mark it experimental, but don't delete it.

This is (a) useful for continued development and experimentation and
(b) will likely be widely deployed (and here I don't mean by my
employer specifically, but mean in general by cloud/virtualization
companies and anyone else that cares about tunnel performance)
regardless of whether upstream linux decides to include it or not.

(Furthermore if the fw/driver is changed to increment inner IP ID
instead of outer IP ID, this will for the most part not be visible to
the end users, since the tunneling is usually internal to the
virtualization provider, and no-one besides their internal network
sees the external IP header.)

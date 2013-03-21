From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] gro: relax ID check in inet_gro_receive()
Date: Thu, 21 Mar 2013 13:07:36 -0700
Message-ID: <CANP3RGfKTQtbhecy=gjxqW+jsnoqEofTspJJfdd1_rAk2YNkEw@mail.gmail.com>
References: <1363841553.3333.47.camel@edumazet-glaptop>
	<20130321.114616.279859400813363663.davem@davemloft.net>
	<1363882091.4431.20.camel@edumazet-glaptop>
	<CAM8tLiPh=g1+XqhwKQAH7XyTmpT80j5422VXGjLksxtFxYoxRQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Hsiao-keng Jerry Chu <hkchu@google.com>
To: Dmitry Kravkov <dkravkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:42381 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695Ab3CUUHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 16:07:37 -0400
Received: by mail-ob0-f170.google.com with SMTP id wc20so3342312obb.29
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 13:07:36 -0700 (PDT)
In-Reply-To: <CAM8tLiPh=g1+XqhwKQAH7XyTmpT80j5422VXGjLksxtFxYoxRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is correct: ID only for one of the headers can be handled with current FW/HW, for other DF is set.

I would prefer for IP ID to be correctly incremented on the inner IPv4
packet rather than the outer IPv4.
Could that be changed?

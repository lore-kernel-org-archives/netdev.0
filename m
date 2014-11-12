From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Tue, 11 Nov 2014 18:29:56 -0800
Message-ID: <1415759396.17262.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
	 <CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
	 <1415748160.2292.8.camel@localhost>
	 <CAHA+R7MgjOKuVY_egNz2SOWZG6X2rkFGfcaP0PiMKc_YVKAULA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35188 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933039AbaKLCaD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 21:30:03 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn18so2143674igb.9
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 18:30:01 -0800 (PST)
In-Reply-To: <CAHA+R7MgjOKuVY_egNz2SOWZG6X2rkFGfcaP0PiMKc_YVKAULA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-11 at 16:39 -0800, Cong Wang wrote:

> Sounds like over-kill to have a new device just for not worrying about mac.
> Or you mean our neigh table doesn't scale?

Some environments simply do not allow having multiple MAC, it is not a
linux problem with neigh table.

Linux hosts can be attached to switches with a very strict security
policy : One (or few) mac address per port.

http://en.wikipedia.org/wiki/CAM_Table

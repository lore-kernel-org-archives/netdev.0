From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: [PATCH net-next 1/1] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Wed, 12 Nov 2014 00:22:40 +0100
Message-ID: <1415748160.2292.8.camel@localhost>
References: <1415744984-25802-1-git-send-email-maheshb@google.com>
	 <CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
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
Received: from mx1.redhat.com ([209.132.183.28]:50041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbaKKXWw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2014 18:22:52 -0500
In-Reply-To: <CAHA+R7OZxCLFYetGHONWkL7uzGur=xSc=ASBT4i5EEeS2Xzwog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-11-11 at 15:12 -0800, Cong Wang wrote:
> On Tue, Nov 11, 2014 at 2:29 PM, Mahesh Bandewar <maheshb@google.com> wrote:
> > This driver is very similar to the macvlan driver except that it
> > uses L3 on the frame to determine the logical interface while
> > functioning as packet dispatcher. It inherits L2 of the master
> > device hence the packets on wire will have the same L2 for all
> > the packets originating from all virtual devices off of the same
> > master device.
> 
> Why do we need this from the beginning?
> IOW, what problem does this solve while macvlan doesn't?

I think it is good to reduce the number of mac addresses before a NIC
switches into promisc mode.

Bye,
Hannes

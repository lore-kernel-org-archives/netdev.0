From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] TX throttling bug-fixing patch of AX88179_178A
Date: Mon, 22 Jul 2013 19:38:32 +0100
Message-ID: <1374518312.1635.29.camel@bwh-desktop.uk.level5networks.com>
References: <1374311809-4155-1-git-send-email-freddy@asix.com.tw>
	 <1374512879.4990.19.camel@edumazet-glaptop>
	 <CANEJEGvPc56ePP=_bxfA4PZfsM3vw=MsRjbWwrFBC3eP-GtzZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Freddy Xin <freddy@asix.com.tw>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ASIX Louis =?UTF-8?Q?=5B=E8=98=87=E5=A8=81=E9=99=B8=5D?=
	<louis@asix.com.tw>, "Allan Chou" <allan@asix.com.tw>
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38316 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932629Ab3GVSih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 14:38:37 -0400
In-Reply-To: <CANEJEGvPc56ePP=_bxfA4PZfsM3vw=MsRjbWwrFBC3eP-GtzZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-07-22 at 11:29 -0700, Grant Grundler wrote:
> On Mon, Jul 22, 2013 at 10:07 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> ...
> > I guess that if a driver does not advertise NETIF_F_SG, this
> > skb_linearize() call is not needed : All frames reaching your xmit
> > function should already be linear
> 
> As Ben Hutchings pointed out, hw_features is still setting this...but
> I'm not sure how that matters.
> 
> ax88179_set_features() doesn't allow setting SG or TSO features.  But
> I expect it would be "not too difficult" to add such that ethtool
> could set those features after boot.
[...]

It already can.  That's what putting feature flags in hw_features does.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

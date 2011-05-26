From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Thu, 26 May 2011 17:11:35 +0800
Message-ID: <BANLkTimEFg0Q=12z2_R4NNQ_VjRH=qhp2w@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
	<BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	<20110524150340.GH21309@gospo.rdu.redhat.com>
	<BANLkTi=UCH8+ZVFwZ96YvFuDqDLwq8ihkQ@mail.gmail.com>
	<20110525150144.GB11867@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:46029 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab1EZJLf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 05:11:35 -0400
Received: by iwn34 with SMTP id 34so414493iwn.19
        for <netdev@vger.kernel.org>; Thu, 26 May 2011 02:11:35 -0700 (PDT)
In-Reply-To: <20110525150144.GB11867@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 11:01 PM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> While thats a fine rule to draw a distinction on, it also creates oth=
er
> organizational oddities. =C2=A0By this reasoning, the loopback/tun-ta=
p and xen
> netfront drivers should also be moved to /net. =C2=A0While this might=
 be an ok move
> to make, I think we can all agree, that while they don't touch specif=
ic
> hardware, they implement instances of the driver model, and as such a=
re
> reasonably placed in /drivers.
>

Hmm, after reading Andy's comments again, I think his point is
probably bridge has STP management code which makes a difference
with bonding, but you know, we have 802.3ad in bonding too.

> This is really a false assertion. =C2=A0Theres nothing more or less h=
ard about
> finding bonding code in /drivers than there is in /net. =C2=A0grep an=
d find let you
> locate the code in either place equally well, and cscope really makes=
 it all
> moot anyway.
>

Sometimes cscope sucks, especially when you meet function pointers
which are pretty common in net code. When I grep netpoll code, I have t=
o
do `grep ndo_netpoll_setup -nr net/  drivers/net`, if bonding were in n=
et/
`grep -nr net/` is enough. 'netdev_rx_handler_register' too.

From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Wed, 25 May 2011 20:43:21 +0800
Message-ID: <BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
	<BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	<20110524163323.GB28521@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65141 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757768Ab1EYMnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2011 08:43:21 -0400
Received: by mail-iy0-f174.google.com with SMTP id 14so6154932iyb.19
        for <netdev@vger.kernel.org>; Wed, 25 May 2011 05:43:21 -0700 (PDT)
In-Reply-To: <20110524163323.GB28521@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2011 at 12:33 AM, Neil Horman <nhorman@tuxdriver.com> w=
rote:
> This all sounds like change for the sake of change to me. =C2=A0I don=
't see any
> compelling argument for moving bonding (or bridging or vlans, etc) ar=
ound at
> all. =C2=A0All of these software drivers have feet in multple subsyst=
ems, but that
> just means that theres not going to be a compelling argument to move =
them any
> place, =C2=A0at least not without an immediate subsequent argument th=
at it really
> belonged back where it was. =C2=A0Unless you can show a solid benefit=
 to moving the
> code, I don't see why any reorganization is needed.

Well, as a people who worked on bonding code, I have no problem to know
bonding code is under drivers/net/, but for people who don't know this,=
 probably
net/ is the first place they want to search.

The other similar thing is that pktgen is in net/core/ while netconsole=
 is in
drivers/net/, which seems a little strange too.

vlan vs macvlan is the third example.

In short, there are three callers of netdev_rx_handler_register(), macv=
lan,
bonding and bridge, only bridge code stays in net/ directory.

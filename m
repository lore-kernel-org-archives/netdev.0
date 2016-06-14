From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 14 Jun 2016 14:35:21 -0400 (EDT)
Message-ID: <20160614.143521.2085426866285759820.davem@davemloft.net>
References: <201606141828.10969@pali>
	<20160614164017.GB14477@kroah.com>
	<201606141847.36109@pali>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, andrew@lunn.ch,
	mario_limonciello@dell.com, hayeswang@realtek.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, anthony.wong@canonical.com
To: pali.rohar@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201606141847.36109@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Pali Roh=E1r <pali.rohar@gmail.com>
Date: Tue, 14 Jun 2016 18:47:36 +0200

> You have never seen two ethernet cards with same MAC addresses? Right=
 I=20
> have not seen two USB, but there is non zero chance that could happen=
=2E=20

It would be an error scenerio, and something to be avoided.

It is a valid and correct assumption that one is able to put
several devices at the same time on the same physical network
and expect it to work.

The behavior added by the change in question invalidates that.

I'm trying to consider the long term aspects of this, which is that if
more devices adopt this scheme we're in trouble if we blindly
interpret the MAC address in this way.

This firmware MAC property facility seems to be designed with only an
extremely narrow use case being considered.

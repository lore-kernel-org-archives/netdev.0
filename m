From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Refactor lan9303_xxx_packet_processing
Date: Mon, 31 Jul 2017 15:22:36 +0200
Message-ID: <20170731132236.GB24562@lunn.ch>
References: <20170731113355.4284-1-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170731113355.4284-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2017 at 01:33:53PM +0200, Egil Hjelmeland wrote:
> First patch: 
> Change lan9303_enable_packet_processing,
> lan9303_disable_packet_processing():
> Pass port number (0,1,2) as parameter instead of port offset.
> Plus replaced a constant 0x400 with LAN9303_SWITCH_PORT_REG()

Hi Egil

The cover note and the commit message should concentrate on the Why,
not the What. I can see the What by reading the patch.

Why do you want to pass port numbers?

Note that for netdev, the cover note also ends up in git as part of
the history.

   Andrew

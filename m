From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA mv88e6xxx RX frame errors and TCP/IP RX failure
Date: Thu, 31 Aug 2017 00:06:31 +0200
Message-ID: <20170830220631.GM22289@lunn.ch>
References: <CAJ+vNU0VzgDkH-ksHgaA0cn3nbCOfcUs_BU90v6xw_QappssgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Tim Harvey <tharvey@gateworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJ+vNU0VzgDkH-ksHgaA0cn3nbCOfcUs_BU90v6xw_QappssgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 30, 2017 at 12:53:56PM -0700, Tim Harvey wrote:
> Greetings,
> 
> I'm seeing RX frame errors when using the mv88e6xxx DSA driver on
> 4.13-rc7. The board I'm using is a GW5904 [1] which has an IMX6 FEC
> MAC (eth0) connected via RGMII to a MV88E6176 with its downstream
> P0/P1/P2/P3 to front panel RJ45's (lan1-lan4).

Hi Tim

Can you confirm the counter is this one:

                       /* Report late collisions as a frame error. */
                        if (status & (BD_ENET_RX_NO | BD_ENET_RX_CL))
                                ndev->stats.rx_frame_errors++;

I don't see anywhere else frame errors are counted, but it would be
good to prove we are looking in the right place.

     Andrew

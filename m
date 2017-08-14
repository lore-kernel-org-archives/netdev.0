From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 01/11] net: dsa: legacy: assign dst->applied
Date: Tue, 15 Aug 2017 00:58:20 +0200
Message-ID: <20170814225820.GJ16885@lunn.ch>
References: <20170814222242.10643-1-vivien.didelot@savoirfairelinux.com>
 <20170814222242.10643-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Egil Hjelmeland <privat@egil-hjelmeland.no>,
        John Crispin <john@phrozen.org>,
        Woojung Huh <Woojung.Huh@microchip.com>,
        Sean Wang <sean.wang@mediatek.com>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Maxime Hadjinlian <maxime@devialet.com>,
        Chris Healy <cphealy@gmail.com>,
        Maxim Uvarov <muvarov@gmail.com>,
        Stefan Eichenberger <eichest@gmail.com>,
        Jason Cobham <jcobham@questertangent.com>,
        Juergen Borleis <jbe@pengutronix.de>,
        Tobias Waldekranz <tobias@waldekranz.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170814222242.10643-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 14, 2017 at 06:22:32PM -0400, Vivien Didelot wrote:
> The "applied" boolean of the dsa_switch_tree is only set in the new
> bindings. This patch sets it in the legacy code as well.

What is missing here is: Why? 

I see the next patch does a WARN_ON(!applied). Why have a WARN_ON?

  Andrew

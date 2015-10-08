From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/6] net: dsa: add port_fdb_prepare
Date: Thu, 8 Oct 2015 17:07:41 +0200
Message-ID: <20151008150741.GS17952@lunn.ch>
References: <1444261711-1829-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444261711-1829-5-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20151008002543.GB31267@lunn.ch>
 <20151008125524.GA1275@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151008125524.GA1275@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Hi Vivien
> > 
> > Bike shedding a bit, but i would call this
> > mv88e6xxx_port_fdb_prepare_add.
> 
> I think port_fdb_prepare is fine because it is the only step that
> actually needs the 2-phase model. del and dump are safe and don't need
> pre-check.

O.K. I don't have a strong opinion, i just think sometime later we
might run into a naming consistency issue. If this does happen, we can
fix it then.

    Andrew

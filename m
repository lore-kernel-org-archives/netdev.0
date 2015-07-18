From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Sat, 18 Jul 2015 16:58:30 +0200
Message-ID: <20150718145830.GA17961@lunn.ch>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150710171027.GB6585@groeck-UX31A>
 <1055594065.210272.1436552447158.JavaMail.zimbra@savoirfairelinux.com>
 <20150710183623.GB19854@roeck-us.net>
 <645518234.216003.1436556107630.JavaMail.zimbra@savoirfairelinux.com>
 <20150710200514.GA9469@groeck-UX31A>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	David <davem@davemloft.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Guenter <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150710200514.GA9469@groeck-UX31A>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Good point. The timeout is most definitely quite large and for sure on
> the safe side. It might make sense to add some statistics gathering to
> see how long the maximum observed delay actually is.

Hi All

Statistics are something which can be used a lot, i bursts and
interactivily. ATU, VTU etc, are much less often used. So different
delays might be justified.

I agree about doing some statistics gathering to determine actual
delays needed.

       Andrew

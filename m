From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] phy/ethtool: Add missing SPEED_<foo> strings
Date: Sun, 02 Apr 2017 19:44:06 -0700
Message-ID: <1491187446.27353.52.camel@perches.com>
References: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
         <c7baf39b-4d4a-93f2-6975-d170a53a6ef2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c7baf39b-4d4a-93f2-6975-d170a53a6ef2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2017-04-02 at 15:29 -0700, Florian Fainelli wrote:
> Le 04/02/17 à 14:30, Joe Perches a écrit :
> > Add all the currently available SPEED_<foo> strings.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> Considering that PHYLIB does not support anything > 10Gbs at the moment,
> I am not sure how useful that is except if we wanted to re-use
> phy_speed_to_str() in other places of the kernel?

phy_print_status() can be used several places already
independent of phylib.

Might as well make it more generic and so more usable.

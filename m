From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/3] net-next: dsa: add new driver for qca8xxx family
Date: Tue, 13 Sep 2016 17:59:26 +0200
Message-ID: <20160913155926.GP11400@lunn.ch>
References: <1473669337-21221-1-git-send-email-john@phrozen.org>
 <1473669337-21221-4-git-send-email-john@phrozen.org>
 <20160913004047.GB3585@lunn.ch>
 <7f9c1463-1cc0-e230-e7fe-dbb434427251@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        qsdk-review@qca.qualcomm.com
To: John Crispin <john@phrozen.org>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7f9c1463-1cc0-e230-e7fe-dbb434427251@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Hi Andrew,
> 
> this function does indeed duplicate the functionality of
> phy_ethtool_get_eee() with the small difference, that e->eee_active is
> also set which phy_ethtool_get_eee() does not set.
> 
> dsa_slave_get_eee() will call phy_ethtool_get_eee() right after the
> get_eee() op has been called. would it be ok to move the code setting
> eee_active to  phy_ethtool_get_eee().

Hi John

I think that is a question for Florian.

  Andrew

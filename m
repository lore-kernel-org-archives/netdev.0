From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3] phy: marvell: Fix and unify reg-init behavior
Date: Tue, 16 Feb 2016 22:30:48 -0800
Message-ID: <06DA03E4-274B-4CD6-BE39-94018C378967@gmail.com>
References: <1455576405-16263-1-git-send-email-clemens.gruber@pqgruber.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Fabio Estevam <festevam@gmail.com>
To: Clemens Gruber <clemens.gruber@pqgruber.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455576405-16263-1-git-send-email-clemens.gruber@pqgruber.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On February 15, 2016 2:46:45 PM PST, Clemens Gruber <clemens.gruber@pqgruber.com> wrote:
>For the Marvell 88E1510, marvell_of_reg_init was called too late, in
>the
>config_aneg function.
>Since commit 113c74d83eef ("net: phy: turn carrier off on phy attach"),
>this lead to the link not coming up at boot anymore, due to the phy
>state machine being stuck at waiting for interrupts (off by default on
>the 88E1510).
>For seven other Marvell PHYs, marvell_of_reg_init was not called at
>all.
>
>Add a generic marvell_config_init function, which in turn calls
>marvell_of_reg_init.
>PHYs, which already have a specific config_init function with a call to
>marvell_of_reg_init, are left untouched. The generic
>marvell_config_init
>function is called for all the others, to get consistent behavior
>across
>all Marvell PHYs.
>
>Signed-off-by: Clemens Gruber <clemens.gruber@pqgruber.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!

-- 
Florian

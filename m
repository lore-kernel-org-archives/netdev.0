From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: smsc911x: handle suspend/resume for mii bus
Date: Wed, 13 Aug 2014 17:09:10 -0300
Message-ID: <CAOMZO5CJ+FejN38Kn-=iKor5GzNHAA7bOdK-mMKJ+nqqBXqAXg@mail.gmail.com>
References: <1407960197-5342-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	stable@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1407960197-5342-1-git-send-email-zonque@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

On Wed, Aug 13, 2014 at 5:03 PM, Daniel Mack <zonque@gmail.com> wrote:
> Since commit a71e3c37960c ("net: phy: Set the driver when registering
> an MDIO bus device"), the ->driver pointers of all mii buses are set to
> the parent device's driver. This means that smsc911x_{suspend,resume}
> will be called for the MII bus at suspend time now, in addition to the
> actual netdev suspend callbacks.

This commit has been reverted in mainline:
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/phy/mdio_bus.c?id=ce7991e8198b80eb6b4441b6f6114bea4a665d66

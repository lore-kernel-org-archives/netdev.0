From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH 1/2] net: ethernet: ethoc: use phydev from struct
 net_device
Date: Mon, 27 Jun 2016 08:32:59 +0200
Message-ID: <20160627063258.GH28466@distanz.ch>
References: <1466865222-11840-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch, colin.king@canonical.com,
	f.fainelli@gmail.com, jcmvbkbc@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1466865222-11840-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-06-25 at 16:33:41 +0200, Philippe Reynes <tremyfr@gmail.com> wrote:
> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.

In that case the phy member should also be removed from the definition
of private struct ethoc in the same patch.

Otherwise the patch looks good to me.

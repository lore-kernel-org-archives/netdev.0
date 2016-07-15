From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH v2 1/2] net: ethernet: ethoc: use phydev from struct
 net_device
Date: Fri, 15 Jul 2016 10:40:23 +0200
Message-ID: <20160715084022.GE28466@distanz.ch>
References: <1468569552-24824-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch, colin.king@canonical.com,
	f.fainelli@gmail.com, jcmvbkbc@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1468569552-24824-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-07-15 at 09:59:11 +0200, Philippe Reynes <tremyfr@gmail.com> wrote:
> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>

Thanks

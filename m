From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: cavium: octeon: use phydev from
 struct net_device
Date: Mon, 04 Jul 2016 16:01:07 -0700 (PDT)
Message-ID: <20160704.160107.1409793991355614529.davem@davemloft.net>
References: <1467495420-23359-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, ivecera@redhat.com, a@unstable.cc,
	fw@strlen.de, david.daney@cavium.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467495420-23359-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  2 Jul 2016 23:36:59 +0200

> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phy in the private structure, and update the driver to use the
> one contained in struct net_device.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.

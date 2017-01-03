From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dlink: dl2k: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 02 Jan 2017 19:31:25 -0500 (EST)
Message-ID: <20170102.193125.265240166456889578.davem@davemloft.net>
References: <1483300166-22297-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, a@unstable.cc, fw@strlen.de, jarod@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483300166-22297-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  1 Jan 2017 20:49:26 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> The previous implementation of set_settings was modifying
> the value of speed and duplex, but with the new API, it's not
> possible. The structure ethtool_link_ksettings is defined
> as const.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atheros: atl1e: use new api
 ethtool_{get|set}_link_ksettings
Date: Sun, 13 Nov 2016 13:49:13 -0500 (EST)
Message-ID: <20161113.134913.1216834393358431093.davem@davemloft.net>
References: <1478989011-11078-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478989011-11078-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat, 12 Nov 2016 23:16:51 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> The previous implementation of set_settings was modifying
> the value of advertising, but with the new API, it's not
> possible. The structure ethtool_link_ksettings is defined
> as const.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.

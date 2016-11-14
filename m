From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: atheros: atl2: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 14 Nov 2016 13:38:22 -0500 (EST)
Message-ID: <20161114.133822.877802428352509301.davem@davemloft.net>
References: <1479059608-32456-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, jarod@redhat.com,
        ben@decadent.org.uk, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479059608-32456-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun, 13 Nov 2016 18:53:28 +0100

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

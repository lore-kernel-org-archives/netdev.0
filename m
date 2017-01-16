From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net: marvell: skge: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 16 Jan 2017 09:29:51 -0800
Message-ID: <20170116092951.3b577463@xeon-e3>
References: <1484395708-4107-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1484395708-4107-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Jan 2017 13:08:28 +0100
Philippe Reynes <tremyfr@gmail.com> wrote:

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> The callback set_link_ksettings no longer update the value
> of advertising, as the struct ethtool_link_ksettings is
> defined as const.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Did you test this on real hardware?

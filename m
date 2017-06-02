From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: marvell: make two functions static
Date: Fri, 2 Jun 2017 16:00:14 +0200
Message-ID: <20170602140014.GK12261@lunn.ch>
References: <20170602111424.31287-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170602111424.31287-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2017 at 12:14:24PM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> functions m88e1510_get_temp_critical and m88e1510_get_temp_alarm can be
> made static as they not need to be in global scope.
> 
> Cleans up sparse warnings:
>  "symbol 'm88e1510_get_temp_alarm' was not declared. Should it be static?"
>  "symbol 'm88e1510_get_temp_critical' was not declared. Should it be 
>   static?"

Hi Colin

What about m88e1510_get_temp_alarm()? That should also have a static.

Thanks
     Andrew

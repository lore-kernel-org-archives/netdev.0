From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: fix error code in
 mv88e6390_serdes_power()
Date: Sat, 24 Jun 2017 05:21:24 +0200
Message-ID: <20170624032124.GI4875@lunn.ch>
References: <20170623151703.stzh2ur3wizbylbi@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170623151703.stzh2ur3wizbylbi@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2017 at 06:17:04PM +0300, Dan Carpenter wrote:
> We're accidentally returning the wrong variable.  "cmode" is
> uninitialized at this point so it causes a static checker warning.
> 
> Fixes: 6335e9f2446b ("net: dsa: mv88e6xxx: mv88e6390X SERDES support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew

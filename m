From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH v2] net: cpsw: fix obtaining mac address for am3517
Date: Fri, 28 Oct 2016 08:52:14 -0700
Message-ID: <20161028155213.2t3nwwe3lqaynaer@atomide.com>
References: <1477668756-2651-1-git-send-email-jhofstee@victronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "open list:TI ETHERNET SWITCH DRIVER (CPSW)"
        <linux-omap@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Jeroen Hofstee <jhofstee@victronenergy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1477668756-2651-1-git-send-email-jhofstee@victronenergy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jeroen Hofstee <jhofstee@victronenergy.com> [161028 08:33]:
> Commit b6745f6e4e63 ("drivers: net: cpsw: davinci_emac: move reading mac
> id to common file") did not only move the code for an am3517, it also
> added the slave parameter, resulting in an invalid (all zero) mac address
> being returned for an am3517, since it only has a single emac and the slave
> parameter is pointing to the second. So simply always read the first and
> valid mac-address for a ti,am3517-emac.

And others davinci_emac.c users can have more than one. So is the
reason the slave parameter points to the second instance because
of the location in the hardware?

Regards,

Tony

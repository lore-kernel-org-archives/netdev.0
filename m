From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: cpsw: fix obtaining mac address for am3517
Date: Thu, 20 Oct 2016 23:38:52 -0700
Message-ID: <20161021063851.6frul6pemo52i7ot@atomide.com>
References: <1476993351-23065-1-git-send-email-jhofstee@victronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeroen Hofstee <jhofstee@victronenergy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1476993351-23065-1-git-send-email-jhofstee@victronenergy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jeroen Hofstee <jhofstee@victronenergy.com> [161020 12:57]:
> Commit b6745f6e4e63 ("drivers: net: cpsw: davinci_emac: move reading mac
> id to common file") did not only move the code for an am3517, it also
> added the slave parameter, resulting in a invalid (all zero) mac address
> being returned. So change it back to always read from slave zero, so it
> works again.

Hmm doesn't this now break it for cpsw with two instances? We may need
am3517 specific quirk flag instead?

Regards,

Tony

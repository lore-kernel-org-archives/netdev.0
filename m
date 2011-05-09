From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH] [RESEND] iwl4965: drop a lone pr_err()
Date: Mon, 9 May 2011 13:06:22 +0200
Message-ID: <20110509110621.GA2294@redhat.com>
References: <1304771519.2227.6.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304771519.2227.6.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, May 07, 2011 at 02:31:59PM +0200, Paul Bolle wrote:
> iwl4965_rate_control_register() prints a message at KERN_ERR level. It
> looks like it's just a debugging message, so pr_err() seems to be
> overdone. But none of the similar functions in drivers/net/wireless
> print a message, so let's just drop it entirely.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Previously sent for (I guess) v2.6.39-rc2. Still present in v2.6.39-rc6.

This patch is already applied in wireless-next ...

commit a22e93f5d819f11d2a2d6332e20ff5b462e5c208
Author: Paul Bolle <pebolle@tiscali.nl>
Date:   Thu Apr 7 20:40:32 2011 +0200

    iwl4965: drop a lone pr_err()
    
    iwl4965_rate_control_register() prints a message at KERN_ERR level.
It
    looks like it's just a debugging message, so pr_err() seems to be
    overdone. But none of the similar functions in drivers/net/wireless
    print a message, so let's just drop it.
    
    Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
    Signed-off-by: John W. Linville <linville@tuxdriver.com>

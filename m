From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Mon, 13 Sep 2004 08:59:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913065958.GC12185@wotan.suse.de>
References: <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain> <20040911142116.GL4431@wotan.suse.de> <1094933731.2343.109.camel@jzny.localdomain> <20040911174535.2acbb957.davem@davemloft.net> <20040912100114.GB11484@havoc.gtf.org> <20040912102529.GA27096@wotan.suse.de> <20040912161604.GA23366@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@davemloft.net>,
        hadi@cyberus.ca, herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040912161604.GA23366@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 12, 2004 at 12:16:05PM -0400, Jeff Garzik wrote:
> Incorrect, you are changing the callsites, which -does- affect every
> driver.

Please read the code before making such claims. 

The new return code is _only_ checked when NETIF_F_LLTX is set. 
A driver that doesn't set this new flag won't ever recognize 
any difference.

-Andi

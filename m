From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] NETIF_F_LLTX for devices 2
Date: Mon, 13 Sep 2004 12:10:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4145C65B.4050703@pobox.com>
References: <20040908072408.GI27886@wotan.suse.de> <1094629677.1089.155.camel@jzny.localdomain> <20040908134713.1bcd46d3.davem@davemloft.net> <1094823215.1121.129.camel@jzny.localdomain> <20040911142116.GL4431@wotan.suse.de> <1094933731.2343.109.camel@jzny.localdomain> <20040911174535.2acbb957.davem@davemloft.net> <20040912100114.GB11484@havoc.gtf.org> <20040912102529.GA27096@wotan.suse.de> <20040912161604.GA23366@havoc.gtf.org> <20040913065958.GC12185@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        herbert@gondor.apana.org.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20040913065958.GC12185@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andi Kleen wrote:
> On Sun, Sep 12, 2004 at 12:16:05PM -0400, Jeff Garzik wrote:
> 
>>Incorrect, you are changing the callsites, which -does- affect every
>>driver.
> 
> 
> Please read the code before making such claims. 
> 
> The new return code is _only_ checked when NETIF_F_LLTX is set. 
> A driver that doesn't set this new flag won't ever recognize 
> any difference.


I read the code :)

The basic premise is that one should be _really_ conservative when 
touching the core RX and TX paths.  Regardless of how safe _you_ feel 
the code is, it is very new, under-analyzed, and untried.

The NAPI-related bug recently fixed in tg3 is an example of the 
unintended consequences of using this new feature.

	Jeff

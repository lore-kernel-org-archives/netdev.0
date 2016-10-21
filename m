From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH] net: cpsw: fix obtaining mac address for am3517
Date: Fri, 21 Oct 2016 02:51:38 -0700
Message-ID: <20161021095137.ypyr7wnwzhum65ua@atomide.com>
References: <1476993351-23065-1-git-send-email-jhofstee@victronenergy.com>
 <20161021063851.6frul6pemo52i7ot@atomide.com>
 <b713c697-3e42-4621-5d65-ab69c979d8be@victronenergy.com>
 <20161021075317.767cu7qkmcn4k4e4@atomide.com>
 <6dbeca0a-65ad-3a1c-2fe5-60023d83dabd@victronenergy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Mugunthan V N <mugunthanvnm@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeroen Hofstee <jhofstee@victronenergy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6dbeca0a-65ad-3a1c-2fe5-60023d83dabd@victronenergy.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jeroen Hofstee <jhofstee@victronenergy.com> [161021 02:31]:
> Aaah, lets wait a sec. I just saw there is another user of this function,
> so above is simply not true....
> 
>     if (of_machine_is_compatible("ti,dra7"))
>         return davinci_emac_3517_get_macid(dev, 0x514, slave, mac_addr);

Oh OK, then this will produce duplicate macs.

> So let me check if I don't break that one..... or better, let me send a v2,
> which
> changes the caller to pass slave as 0 here?
> 
>     if (of_device_is_compatible(dev->of_node, "ti,am3517-emac"))
>         return davinci_emac_3517_get_macid(dev, 0x110, slave, mac_addr);
> 

Yeah that sounds good to me.

Regards,

Tony

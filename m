From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kexec: Export kexec_in_progress to modules
Date: Thu, 20 Oct 2016 21:54:10 -0400 (EDT)
Message-ID: <20161020.215410.650162338407203719.davem@davemloft.net>
References: <1477012516-20470-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com,
        kexec@lists.infradead.org, linux-kernel@vger.kernel.org,
        sfr@canb.auug.org.au
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477012516-20470-1-git-send-email-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 20 Oct 2016 18:15:16 -0700

> The bcm_sf2 driver uses kexec_in_progress to know whether it can power
> down an integrated PHY during shutdown, and can be built as a module.
> Other modules may be using this in the future, so export it.
> 
> Fixes: 2399d6143f85 ("net: dsa: bcm_sf2: Prevent GPHY shutdown for kexec'd kernels")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
> Eric, David, Stephen,
> 
> The offending commit is in David's net.git tree, so it would probably make
> sense to route the fix through the same tree.

Ok, I'll apply this, thanks Florian.

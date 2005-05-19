From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was
 Ethernet Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 13:39:59 -0700
Message-ID: <20050519133959.566989da@dxpl.pdx.osdl.net>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2005 18:28:26 +0300 (EEST)
"Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro> wrote:

> Hello!
> 
> The attached patch, makes the bridge to select features (almost all) only 
> if _all_ devices supports them.
> The patch was tested (create a bridge, add an interface, remove the 
> interface and always check features flags).
> 
> What do you think?
> 
> Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>

Okay, but just open code this, don't need BR_FEAT_MASK
and br_features_change.

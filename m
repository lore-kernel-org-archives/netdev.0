From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 11:06:53 -0500
Message-ID: <200505191106.53136.jdmason@us.ibm.com>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
In-Reply-To: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch only enables the features which are common between all of the 
bridged devices (at the time of their addition to the bridge).  It overlooks 
the cases where not all of the adapters have the same features, or where the 
user has changed the enablement of a certain feature (via ethtool).  

Thanks,
Jon

On Thursday 19 May 2005 10:28 am, Catalin(ux aka Dino) BOIE wrote:
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
> ---
> Catalin(ux aka Dino) BOIE
> catab at deuroconsult.ro
> http://kernel.umbrella.ro/

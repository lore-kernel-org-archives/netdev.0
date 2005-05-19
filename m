From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones
Date: Thu, 19 May 2005 11:53:53 -0700 (PDT)
Message-ID: <20050519.115353.102574650.davem@davemloft.net>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
	<200505191106.53136.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <200505191106.53136.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Thu, 19 May 2005 11:06:53 -0500

> This patch only enables the features which are common between all of the 
> bridged devices (at the time of their addition to the bridge).  It overlooks 
> the cases where not all of the adapters have the same features, or where the 
> user has changed the enablement of a certain feature (via ethtool).  

There is not valid setting other than the subset of
what the devices all support.

Yes, the bridging code should listen for network device
events when netdev->flag settings change, but otherwise
this is the way to implement this.  Just like bonding
does.

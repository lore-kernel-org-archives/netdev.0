From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM
 support
Date: Mon, 23 May 2005 14:20:09 -0700 (PDT)
Message-ID: <20050523.142009.74748115.davem@davemloft.net>
References: <20050523210757.GB5910@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <20050523210757.GB5910@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Subject: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM support
Date: Mon, 23 May 2005 16:07:57 -0500

> Added support to ethtool for NETIF_F_HW_CSUM.
> 
> Signed-off-by: Jon Mason <jdmason@us.ibm.com>

You cannot blindly set these flags, you need to provide
a method for the driver to override the implementation of
this method so it can return and error if it cannot provide
support for this feature.

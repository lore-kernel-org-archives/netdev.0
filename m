From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM support
Date: Mon, 23 May 2005 16:32:55 -0500
Message-ID: <200505231632.55476.jdmason@us.ibm.com>
References: <20050523210757.GB5910@us.ibm.com> <20050523.142009.74748115.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050523.142009.74748115.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 23 May 2005 04:20 pm, David S. Miller wrote:
> From: Jon Mason <jdmason@us.ibm.com>
> Subject: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM support
> Date: Mon, 23 May 2005 16:07:57 -0500
>
> > Added support to ethtool for NETIF_F_HW_CSUM.
> >
> > Signed-off-by: Jon Mason <jdmason@us.ibm.com>
>
> You cannot blindly set these flags, you need to provide
> a method for the driver to override the implementation of
> this method so it can return and error if it cannot provide
> support for this feature.

I am only adding a generic function which gives the ability to use 
NETIF_F_HW_CSUM for ethtool tx offload (instead of only using 
NETIF_F_IP_CSUM).

If ethtool_set_tx_csum does not point to ethtool_op_set_tx_csum or 
ethtool_op_set_tx_hw_csum (or a local driver function) then it will return an 
error.  Isn't this sufficient (as it is what currently happening), or am I 
not sufficently understanding the problem?

Thanks,
Jon

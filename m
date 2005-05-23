From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH linux-2.6.12-rc4-mm1] ethtool: Add NETIF_F_HW_CSUM
 support
Date: Mon, 23 May 2005 14:48:50 -0700 (PDT)
Message-ID: <20050523.144850.03976904.davem@davemloft.net>
References: <20050523210757.GB5910@us.ibm.com>
	<20050523.142009.74748115.davem@davemloft.net>
	<200505231632.55476.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <200505231632.55476.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Mon, 23 May 2005 16:32:55 -0500

> If ethtool_set_tx_csum does not point to ethtool_op_set_tx_csum or
> ethtool_op_set_tx_hw_csum (or a local driver function) then it will
> return an error.  Isn't this sufficient (as it is what currently
> happening), or am I not sufficently understanding the problem?

Ok, that looks right.

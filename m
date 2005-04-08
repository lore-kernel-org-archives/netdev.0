From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.12-rc2] bonding: partially back out dev_set_mac_address
Date: Thu, 07 Apr 2005 23:50:01 -0400
Message-ID: <4255FF69.4090208@pobox.com>
References: <200504071959.j37JxZ8g003626@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200504071959.j37JxZ8g003626@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	This patch backs out some of the calls to dev_set_mac_address
> and replaces them with calls to a similar function that does not call
> notifier_call_chain.
> 
> 	The reason for this is that the rtnetlink event handler and its
> descendents make GFP_KERNEL memory allocation requests, and the bonding
> driver makes some of its MAC address change calls from timer context
> with a lock held (notably the ALB mode).
> 
> 	Rearranging the bonding driver to not call this way is a fairly
> involved change; this patch merely reverts one part of bonding to the
> way it used to be.

Do I need to forward this for -rc3?

	Jeff

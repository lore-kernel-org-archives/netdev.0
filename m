From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ibmtr -- convert to new probeing
Date: Fri, 14 Nov 2003 20:07:33 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB57C55.5090602@pobox.com>
References: <20031113112440.2fe0e12c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>,
        "Mike_Phillips@URSCorp.com" <Mike_Phillips@URSCorp.com>
In-Reply-To: <20031113112440.2fe0e12c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> This patch applies against net-drivers-2.5-exp.  The line number offsets assume
> the earlier patchset, but this change doesn't overlap all those ether changes.
> 
> 	* convert ibmtr driver to using the new probe interface -- ibmtr_probe2
> 	* keep old ibmtr_probe for use as init handle because ibmtr_cs uses it
> 	* cleanup error paths in ibmtr_probe1 and module init
> 	* make only used locally functions static
> 	* do request_region before doing i/o
> 	* irq and mem were not really settable as module parameters so removed


Given that there has been some other activity in this driver, I would 
prefer to wait for Mike's ACK, before applying to net-drivers-2.5-exp 
(and eventually 2.6 when it re-opens).

	Jeff

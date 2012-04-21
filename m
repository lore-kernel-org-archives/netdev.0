From: David Daney <david.s.daney@gmail.com>
Subject: Re: [PATCH v5 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Sat, 21 Apr 2012 14:25:51 -0700
Message-ID: <4F9325DF.7020003@gmail.com>
References: <1334791254-15987-1-git-send-email-ddaney.cavm@gmail.com>        <1334791254-15987-3-git-send-email-ddaney.cavm@gmail.com> <20120421.153201.2103447307695063734.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, grant.likely@secretlab.ca,
	rob.herring@calxeda.com, devicetree-discuss@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, afleming@gmail.com,
	galak@kernel.crashing.org, david.daney@cavium.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120421.153201.2103447307695063734.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/21/2012 12:32 PM, David Miller wrote:
> From: David Daney<ddaney.cavm@gmail.com>
> Date: Wed, 18 Apr 2012 16:20:53 -0700
>
>> +config MDIO_BUS_MUX
>> +	tristate
>> +	help
>> +	  This module provides a driver framework for MDIO bus
>> +	  multiplexers which connect one of several child MDIO busses
>> +	  to a parent bus.  Switching between child busses is done by
>> +	  device specific drivers.
>> +
> This driver uses OF and OF_MDIO, and therefore need dependencies upon
> them.  Otherwise it can be enabled in configurations which will result
> in build failures.

Note that this symbol cannot be selected by the user, only indirectly 
via the MDIO_BUS_MUX_GPIO symbol (in patch 3/3) which has the proper 
dependencies.

If we were to specify the dependencies in both places, we gain nothing other than duplication of information.

However, if you insist, I will of course add it here too.

David Daney

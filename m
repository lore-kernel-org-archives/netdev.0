From: David Daney <david.daney@cavium.com>
Subject: Re: [PATCH v4 3/3] netdev/of/phy: Add MDIO bus multiplexer driven
 by GPIO lines.
Date: Wed, 18 Apr 2012 09:24:56 -0700
Message-ID: <4F8EEAD8.8050205@cavium.com>
References: <1334683966-12112-1-git-send-email-ddaney.cavm@gmail.com>	<1334683966-12112-4-git-send-email-ddaney.cavm@gmail.com> <20120417.225308.1588669089502246200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ddaney.cavm@gmail.com, grant.likely@secretlab.ca,
	rob.herring@calxeda.com, devicetree-discuss@lists.ozlabs.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, afleming@gmail.com,
	galak@kernel.crashing.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120417.225308.1588669089502246200.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/17/2012 07:53 PM, David Miller wrote:
> From: David Daney<ddaney.cavm@gmail.com>
> Date: Tue, 17 Apr 2012 10:32:46 -0700
>
>> From: David Daney<david.daney@cavium.com>
>>
>> The GPIO pins select which sub bus is connected to the master.
>>
>> Initially tested with an sn74cbtlv3253 switch device wired into the
>> MDIO bus.
>>
>> Signed-off-by: David Daney<david.daney@cavium.com>
>
> Are you sure the Kconfig dependencies are sufficient?  This code seems
> to depend upon OF, and in particular the OF_MDIO stuff.
>

You are correct.  Should I:

A) Create a patch to fix the dependencies it on top of the previous set?

B) Regenerate the entire set with said patch rolled in?

Thanks,
David Daney

From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: Re: [PATCH] ethernet/arc/arc_emac - Add new driver
Date: Fri, 7 Jun 2013 12:37:24 +0000
Message-ID: <4881796E12491D4BB15146FE0209CE643F5C8E99@DE02WEMBXB.internal.synopsys.com>
References: <1370348510-23754-1-git-send-email-abrodkin@synopsys.com>
 <1505761.5DsauZd6eq@wuerfel>
 <4881796E12491D4BB15146FE0209CE643F5C77EC@DE02WEMBXB.internal.synopsys.com>
 <2468036.im0srnzmHT@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/07/2013 04:13 PM, Arnd Bergmann wrote:
>>> I wonder if it would be better to name the directory "synopsys" or
>>> "designware" rather than "arc" now. Is there a chance that the same
>>> controller is used on non-arc CPUs?
>>
>> The thing is - "arc_emac" is a custom ARC's (that was implemented before
>> acquisition of ARC by Synopsys) IP (it's not an IC - just a part of CPU)
>> Ethernet controller that only exists in some legacy FPGA boards we
>> (ex-ARC and our customers) still use a lot in development process.
>>
>> Synopsys itself doesn't actively sell this device so there's no point in
>> putting ARC EMAC into Synopsys folder.
>>
>> And indeed we don't expect this device to be used with non-ARC CPU's.

I'm wondering if my clarification above makes sense and I may leave this 
driver in "ethernet/arc" or you still prefer it to be under 
"ethernet/synopsys"?

-Alexey

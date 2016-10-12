From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH v3 1/4] net: phy: dp83867: Add documentation for optional
 impedance control
Date: Wed, 12 Oct 2016 13:43:57 +0530
Message-ID: <bc9a985b-0623-b1fd-8cc1-575d8b318560@ti.com>
References: <20161006051355.15947-1-mugunthanvnm@ti.com>
 <20161006051355.15947-2-mugunthanvnm@ti.com>
 <20161010131841.GA8391@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Tony Lindgren <tony@atomide.com>,
 netdev@vger.kernel.org, Sekhar Nori <nsekhar@ti.com>,
 linux-kernel@vger.kernel.org, Russell King <linux@armlinux.org.uk>,
 linux-omap@vger.kernel.org, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161010131841.GA8391@rob-hp-laptop>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Monday 10 October 2016 06:48 PM, Rob Herring wrote:
> On Thu, Oct 06, 2016 at 10:43:52AM +0530, Mugunthan V N wrote:
>> Add documention of ti,impedance-control which can be used to
> 
> Needs updating.

Oops, will update this in next version.

> 
>> correct MAC impedance mismatch using phy extended registers.
>>
>> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
>> ---
>>  Documentation/devicetree/bindings/net/ti,dp83867.txt | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/Documentation/devicetree/bindings/net/ti,dp83867.txt b/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> index 5d21141..85bf945 100644
>> --- a/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> +++ b/Documentation/devicetree/bindings/net/ti,dp83867.txt
>> @@ -9,6 +9,18 @@ Required properties:
>>  	- ti,fifo-depth - Transmitt FIFO depth- see dt-bindings/net/ti-dp83867.h
>>  		for applicable values
>>  
>> +Optional property:
>> +	- ti,min-output-impedance - MAC Interface Impedance control to set
>> +				    the programmable output impedance to
>> +				    minimum value (35 ohms).
>> +	- ti,max-output-impedance - MAC Interface Impedance control to set
>> +				    the programmable output impedance to
>> +				    maximum value (70 ohms).
> 
> Define what are valid range of values for these.

The values are already mentioned in documentation as 35/70 ohms.
Are you mentioning about the register values?

Regards
Mugunthan V N

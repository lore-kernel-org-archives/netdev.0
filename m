From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones (was Ethernet
 Bridging: Enable Hardware Checksumming)
Date: Thu, 19 May 2005 20:22:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0505192019090.8076@webhosting.rdsbv.ro>
References: <Pine.LNX.4.62.0505191654400.24043@webhosting.rdsbv.ro>
 <200505191106.53136.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200505191106.53136.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 May 2005, Jon Mason wrote:

> This patch only enables the features which are common between all of the
> bridged devices (at the time of their addition to the bridge).  It overlooks
> the cases where not all of the adapters have the same features, or where the
> user has changed the enablement of a certain feature (via ethtool).
>
> Thanks,
> Jon

I agree that the patch doesn't take care of ethtool oprations.
I will correct this.

But, it doesn't overlook the case when "not all of the adapters have the 
same features". If all devices have a feature, it is enabled on the bridge 
interface. Else, it is cleared. Am I missing your point?

Thank you very much for looking over the patch!

> On Thursday 19 May 2005 10:28 am, Catalin(ux aka Dino) BOIE wrote:
>> Hello!
>>
>> The attached patch, makes the bridge to select features (almost all) only
>> if _all_ devices supports them.
>> The patch was tested (create a bridge, add an interface, remove the
>> interface and always check features flags).
>>
>> What do you think?
>>
>> Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>
>> ---
>> Catalin(ux aka Dino) BOIE
>> catab at deuroconsult.ro
>> http://kernel.umbrella.ro/
>

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/

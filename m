From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH 1/2] net: davinci_mdio: reuse for keystone2 arch
Date: Fri, 11 Jul 2014 13:24:52 +0300
Message-ID: <53BFBB74.80104@ti.com>
References: <1404911451-9921-2-git-send-email-grygorii.strashko@ti.com>	<20140709.165232.539576872991411664.davem@davemloft.net>	<53BE8DF7.9090303@ti.com>
	<20140710.123900.1696373067218564684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <santosh.shilimkar-l0cyMroinI0@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
In-Reply-To: <20140710.123900.1696373067218564684.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://linux.davincidsp.com/mailman/options/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=unsubscribe>
List-Archive: <http://linux.davincidsp.com/pipermail/davinci-linux-open-source>
List-Post: <mailto:davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
List-Help: <mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=help>
List-Subscribe: <http://linux.davincidsp.com/mailman/listinfo/davinci-linux-open-source>,
	<mailto:davinci-linux-open-source-request-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org?subject=subscribe>
Sender: <davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>
Errors-To: davinci-linux-open-source-bounces-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
List-Id: netdev.vger.kernel.org

On 07/10/2014 10:39 PM, David Miller wrote:
> From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
> Date: Thu, 10 Jul 2014 15:58:31 +0300
>
>> Hi David,
>>
>> On 07/10/2014 02:52 AM, David Miller wrote:
>>> From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
>>> Date: Wed, 9 Jul 2014 16:10:50 +0300
>>>
>>>>    Required properties:
>>>> -- compatible		: Should be "ti,davinci_mdio"
>>>> +- compatible		: Should be "ti,davinci_mdio" or "ti,keystone-mdio"
>>>
>>> Why the inconsistency in naming schemes?  I don't see any reason
>>> to be different wrt. "_" vs. "-" in the name string.
>>>
>>
>> Hm. Looks like the common way is to use "-", but I can rename it if you insist.
>
> I'm just saying, is there a strong reason to be inconsistent?
>

I've followed the same format as for all latest compatibility strings in 
Kernel. Also I've checked ePAPR and dash is used for all examples there.

"ti,davinci_mdio" was added 2 years ago, so possibly no strict 
convention or review were done then. Now, I can't change 
"ti,davinci_mdio" -> "ti,davinci-mdio" to be consistent with Kernel due 
to compatibility issues.

May be DT Gurus can say more?


Regards,
-grygorii

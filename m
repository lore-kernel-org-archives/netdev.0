From: Andy Fleming <afleming@freescale.com>
Subject: Re: RFC: PHY Abstraction Layer II
Date: Wed, 9 Mar 2005 11:17:54 -0600
Message-ID: <bd227d824fe755c8560aaacff9210d62@freescale.com>
References: <1107b64b01fb8e9a6c84359bb56881a6@freescale.com> <1110334456.32556.21.camel@gaston>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>,
        Embedded PPC Linux list <linuxppc-embedded@ozlabs.org>
In-Reply-To: <1110334456.32556.21.camel@gaston>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Mar 8, 2005, at 20:14, Benjamin Herrenschmidt wrote:

> On Tue, 2005-03-08 at 19:47 -0600, Andy Fleming wrote:
>> I've finally gotten all of ebs's suggestions into the PHY code.  Here
>> is the new version.  It has the following improvements:
>>
>> * All PHYs now determine speed,duplex, etc using the same generic 
>> code,
>> rather than PHY-specific registers.
>
> Some PHY are doing a better job with PHY specific registers I think ...
> The gigabit for example isn't standard, and some PHYs sort-of manage to
> deal with non-autoneg hubs in such a way that the "normal" aneg doesn't
> succeeds, but the phy specific stuff does work. At least from stuff 
> I've
> been told a while ago, I have no direct experience here.

Ah, I should have been a little more clear.  All the currently 
implemented PHY drivers are just using the generic read_status 
function.  Different PHYs can assign their read_status function to be 
PHY-specific

>
>> * The genphy driver works for gigabit PHYs now, as well.  In theory, 
>> if
>> your PHY isn't broken in some way (I've encountered a number that 
>> are),
>> you should be able to just use genphy.
>
> Isn't the speed reporting of gigabit an implementation specific bit in
> lots of PHYs ?

Well, it looks like there are some standard bits which say whether the 
PHY supports gigabit.  I used those.

Andy

From: jamal <hadi@cyberus.ca>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: 20 Mar 2005 08:40:11 -0500
Message-ID: <1111326010.1093.32.camel@jzny.localdomain>
References: <200503192219.j2JMJmDD014063@guinness.s2io.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "'Andi Kleen'" <ak@muc.de>, netdev@oss.sgi.com, leonid@neterion.com,
        jgarzik@pobox.com
To: Leonid Grossman <leonid.grossman@neterion.com>
In-Reply-To: <200503192219.j2JMJmDD014063@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-03-19 at 17:19, Leonid Grossman wrote:

> Sure. I was not asking for a promise to merge the code, only for a rough
> consensus that a HAL-based approach by itself is not a showstopper. 
> Without such a consensus, it doesn't matter if we address other issues,
> right?

Typically theres only one motivation for HALs - maintain the same code
base for 20 OSes. Makes it easier for a small company (not sure if yours
fits that category) to maintain. It doesnt matter how differently you
position or spin it (no offense intended), that is the main if not only
motivation. 

OTOH, you shift the burden of the extra maintainance work to the people
on the Linux side who know may have to understand what your layer does.
This is why people hate it.
I dont think it is sufficient to say your company will be updating the
driver:
- Years from now your company may not be around anymore but your
hardware may still be. Who is going to fix the bugs then?  
- APIs, mechanisms etc change on Linux as well. You become a bottleneck
if nobody understands your HAL because they have to wait for you to make
the changes.
Traditionaly whoever makes the changes on dirver schemes ensures all
drivers are updated. Think positively that this is now offloaded from
you.

My suggestion: have a dedicated resource just for Linux - it is big
enough to justify; maintain HAL for other OSes that will never change, I
bet you whatever works for NDIS probably will continue to work for
vxworks for the next 10 years - not much innovation going on there;-> or
you could claim (bah!) theres stability on those OSes.

cheers,
jamal

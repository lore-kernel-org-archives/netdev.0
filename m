From: gshan <gshan@alcatel-lucent.com>
Subject: Re: [HELP] BAD interrupts
Date: Thu, 24 Dec 2009 06:46:25 -0500
Message-ID: <4B335491.1020203@alcatel-lucent.com>
References: <9F4C7D19E8361D4C94921B95BE08B81BA09038@zin33exm22.fsl.freescale.net>
	<1261608230.3401.16.camel@concordia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	Kumar Gopalpet-B05799 <B05799@freescale.com>
To: michael@ellerman.id.au
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1261608230.3401.16.camel@concordia>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Michael Ellerman wrote:
> On Wed, 2009-12-23 at 19:41 +0530, Kumar Gopalpet-B05799 wrote:
>   
>> Hi all,
>>  
>> I am trying linux 2.6.32-rc3 in SMP mode. I am seeing a lot of BAD
>> interrupts when I do a "cat  /proc/interrupts".
>>  
>> I am running a forwarding application b/w two ethernet ports (ethernet
>> uses gianfar driver).
>>  
>> Has any one observed these BAD interrupts ? If so, can someone help me
>> in understanding why these interrupts come and how to resolve it ?
>>     
>
> You'll need to tell us what platform you're running on.
>
> The BAD interrupts come from ppc_spurious_interrupts. It's a count of
> the number of times we entered do_IRQ() (ie. took an external
> interrupt), but when we asked the interrupt controller which irq it was,
> the interrupt controller said there was no irq.
>
> Depending on your interrupt controller that might happen sometimes for
> valid reasons. Or it might indicate something is setup wrong.
>
> cheers
>   
I think it will help to show us your /proc/interrupts so that how you 
suffered
from bad interrupts.

From: jamal <hadi@cyberus.ca>
Subject: Re: Inaccuracies with SCH_CLK_CPU
Date: 07 Aug 2004 14:54:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1091904889.1041.21.camel@jzny.localdomain>
References: <20040804094310.1d054b3a@dell_ss3.pdx.osdl.net>
	 <41152301.5090405@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41152301.5090405@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-08-07 at 14:44, Patrick McHardy wrote:

> sch_netem's interface is in us, but it doesn't convert the values to 
> psched_us.
> psched_us differ from us with CLK_CPU or CLK_JIFFIES for most values of HZ.
> This patch fixes the problem, but the best solution is to change the 
> interface and pass the time values as psched_us from userspace, as done with 
> rate-tables and I think CBQ. 

Nice catch Patrick.
While you are doing that Stephen, can you also compute the probability
tables in user space? This allows me to take advantage of the schem
later on when i convert gact action which has randomness built in.

> I should have done this for HFSC too, but unlike for 
> sch_netem, I think it's too late to change the interface.

Maybe post 2.6?

cheers,
jamal

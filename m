From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 0/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Tue, 30 Mar 2004 10:37:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40699457.1020304@pobox.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <4068656D.2080103@pobox.com> <20040329211441.B4744@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040329211441.B4744@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>I am pondering taking your latest version of r8169, and moving the 
>>phy-related code from there to 8139cp.c.  Then just add
>>	MODULE_ALIAS("r8169");
>>and deleting r8169.c.
>>
>>The rationale is, 8169 is _exactly_ the same as 8139C+, except the phy 
>>code and one or two bits in the chip registers.  I would rather have 
>>just one codebase, supporting one MAC (i.e. the RX/TX part) and multiple 
>>phys.
> 
> 
> It seems appealing. Do you have a specific schedule in mind ?


schedules are an anathema to me ;-)

I was thinking about getting your initial patches into 2.6.x upstream so
that r8169 users at least have something usable while the phy code gets
moved over to 8139cp.c.

	Jeff

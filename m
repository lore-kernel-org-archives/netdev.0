From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses
Date: Fri, 26 Mar 2004 21:20:36 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040326212036.A26347@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040326192211.GA15319@scream.fjortis.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Henriksson <andreas@fjortis.info>
Content-Disposition: inline
In-Reply-To: <20040326192211.GA15319@scream.fjortis.info>; from andreas@fjortis.info on Fri, Mar 26, 2004 at 08:22:11PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andreas Henriksson <andreas@fjortis.info> :
[...]
> I came to the conclusion that there should be a spinlock in the
> interrupt handler yesterday, but it won't effect me at all since I don't
> have SMP (nor preempt) so I'll leave it for now anyway.

SMP is not needed. If an interrupt is fired at the wrong time, the race
takes place as well.

--
Ueimor

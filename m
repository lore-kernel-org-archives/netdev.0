From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [patch 0/4] 2.6.5-rc2-mm5 - r8169 queue
Date: Mon, 29 Mar 2004 21:14:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040329211441.B4744@electric-eye.fr.zoreil.com>
References: <20040329193604.A4744@electric-eye.fr.zoreil.com> <4068656D.2080103@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4068656D.2080103@pobox.com>; from jgarzik@pobox.com on Mon, Mar 29, 2004 at 01:05:33PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> I am pondering taking your latest version of r8169, and moving the 
> phy-related code from there to 8139cp.c.  Then just add
> 	MODULE_ALIAS("r8169");
> and deleting r8169.c.
> 
> The rationale is, 8169 is _exactly_ the same as 8139C+, except the phy 
> code and one or two bits in the chip registers.  I would rather have 
> just one codebase, supporting one MAC (i.e. the RX/TX part) and multiple 
> phys.

It seems appealing. Do you have a specific schedule in mind ?

--
Ueimor

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] [sparse] get rid of warnings from 8139too driver
Date: Wed, 23 Jun 2004 01:15:56 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040623011556.A28140@electric-eye.fr.zoreil.com>
References: <20040622135122.05be2be1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20040622135122.05be2be1@dell_ss3.pdx.osdl.net>; from shemminger@osdl.org on Tue, Jun 22, 2004 at 01:51:22PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
> Get rid of sparse warnings from 8139too driver. 
> 	* move start_thread which was inline into the open routine (only place called).

I can understand that rtl8139_start_thread() appears a bit late in the file
but I appreciate the virtues of helpers functions as they document what
the code is supposed to achieve. Just mho of course.

--
Ueimor

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] acenic -- update to use alloc_etherdev
Date: Wed, 11 Jun 2003 22:43:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.224305.68068281.davem@redhat.com>
References: <m3y90845nu.fsf@trained-monkey.org>
	<20030611.210445.21901735.davem@redhat.com>
	<3EE81263.4040205@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jes@wildopensource.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <3EE81263.4040205@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Wed, 11 Jun 2003 22:40:51 -0700

   The problem is it doesn't know what irqreturn_t is.  The enclosed
   cribbed from atm/he.c fixes that, but it still redefines local_irq_save etc.

Such compat macros belong in include/linux/interrupt.h and
someone needs to merge that to Marcelo.

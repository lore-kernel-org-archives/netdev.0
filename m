From: Stephen Hemminger <shemminger@osdl.org>
Subject: comx drivers in 2.6
Date: Thu, 17 Jul 2003 16:33:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030717163337.78d123c0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gergely Madarasz <gorgo@itc.hu>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like the comx drivers never got updated for 2.5/2.6.  Some
obvious issues are:
	- lots of use of /proc files without setting the owner field.
	- still using cli/sti
	- no SMP locking on the linked list (which could be changed to list macros)
	  of hardware and protocols.

Just bumped into this while trying to inspect for all the last possible
broken usage of net_device structure.  It is too far behind to address
those issues.

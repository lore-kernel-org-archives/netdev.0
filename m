From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: comx drivers in 2.6
Date: Thu, 17 Jul 2003 19:42:16 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F173458.6060405@pobox.com>
References: <20030717163337.78d123c0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gergely Madarasz <gorgo@itc.hu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030717163337.78d123c0.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> It looks like the comx drivers never got updated for 2.5/2.6.  Some
> obvious issues are:
> 	- lots of use of /proc files without setting the owner field.
> 	- still using cli/sti
> 	- no SMP locking on the linked list (which could be changed to list macros)
> 	  of hardware and protocols.
> 
> Just bumped into this while trying to inspect for all the last possible
> broken usage of net_device structure.  It is too far behind to address
> those issues.


Submit a patch to mark these CONFIG_OBSOLETE.  AFAIK nobody has cared 
for most of them since 2.2...  (munich is an exception)

	Jeff

From: jamal <hadi@cyberus.ca>
Subject: Re: Iproute2: update
Date: 16 Jan 2005 12:09:13 -0500
Message-ID: <1105895352.1091.705.camel@jzny.localdomain>
References: <20050112125903.64d42737@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LDKRqX2mFBn4MHPRkMSB"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050112125903.64d42737@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-LDKRqX2mFBn4MHPRkMSB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Here's one fix

cheers,
jamal

On Wed, 2005-01-12 at 15:59, Stephen Hemminger wrote:
> There is an new version of iproute2 for testing.
> http://developer.osdl.org/dev/iproute2/download/iproute2-2.6.10-ss050112.tar.gz	
> 
> Mostly simple merges, but could have some issues.
> Jamal did I get everything you sent?
> 
> [Masahide Nakamura]
> 	ipmonitor shows IPv6 prefix list notification
> 	update to iproute2 xfrm for ipv6	
> 	
> [Stephen Hemminger]
> 	fix compile warnings when building 64bit system
> 	don't include <asm/byteorder.h>
> 	warning about "ip route nat" no longer supported
> 
> [Catalin(ux aka Dino) BOIE]
> 	fwmark in u32 filters
> 	
> [Andi Kleen]
> 	netlink manual page
> 
> [Thomas Graf]
> 	tc testsuite
> 
> [Jamal Hadi Salim]
> 	iptables tc support
> 	mirror and redirect actions
> 

--=-LDKRqX2mFBn4MHPRkMSB
Content-Disposition: attachment; filename=m_p_tc
Content-Type: text/plain; name=m_p_tc; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- a/tc/m_mirred.c	2005-01-12 15:19:46.000000000 -0500
+++ b-mod/tc/m_mirred.c	2005-01-16 11:51:59.217756280 -0500
@@ -303,7 +303,7 @@
 	return 0;
 }
 
-struct action_util mirred_util = {
+struct action_util mirred_action_util = {
 	.id = "mirred",
 	.parse_aopt = parse_mirred,
 	.print_aopt = print_mirred,

--=-LDKRqX2mFBn4MHPRkMSB--

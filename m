From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 0/3] 2.6.5-netdev2 - r8169 update
Date: Wed, 7 Apr 2004 23:13:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040407231332.A25021@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Srihari Vijayaraghavan <harisri@telstra.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040405235545.A20805@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 05, 2004 at 11:55:45PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following serie of patches applies against 2.6.5 + 2.6.5-netdev2.

- r8169-missing-static.patch
  missing 'static' qualifiers.
  
- r8169-irq-handler-status.patch
  fix status code bogosity for the irq handler if the r8169 interrupt is
  shared.

- r8169-mod_timer.patch
  missing "jiffies +" in mod_timer(). The link recovery code seems to work
  again. 

An update of the patch against 2.6.5 for the whole driver is available for
testers at:
http://www.fr.zoreil.com/people/francois/misc/20040407-2.6.5-r8169.c-stable.patch

--
Ueimor

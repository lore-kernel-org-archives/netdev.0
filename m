From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Sysfs net device device link
Date: Tue, 20 May 2003 20:03:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030520.200338.77050981.davem@redhat.com>
References: <20030520141803.09c75d5b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030520141803.09c75d5b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 20 May 2003 14:18:03 -0700

   This is the second part of the net devices sysfs patch.
   
   It changes most network drivers to set the generic device entry up
   in the net device structure prior to registration.
   
I've applied both of your patches, thanks.

I did have to fix up two things though:

1) One driver used lower-case set_netdev_dev(), easy to fix.
2) Patch conflict with ns83820.c SET_MODULE_OWNER() fix you also
   sent me today, also easily resolved.

Thanks again.

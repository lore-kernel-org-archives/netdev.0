From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.72] mark assert error cases in skbuff unlikely
Date: Thu, 19 Jun 2003 12:37:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619.123740.35020381.davem@redhat.com>
References: <20030619122433.2dc720ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030619122433.2dc720ec.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 19 Jun 2003 12:24:33 -0700

   skbuff.h includes a number of checks for error conditions which can
   be optimized by the compiler.  Use BUG_ON where possible.

Applied, thanks.

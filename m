From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] missing owner field entry on pppoe /proc
Date: Thu, 19 Jun 2003 12:36:25 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030619.123625.38706439.davem@redhat.com>
References: <20030619122024.3d21c0ec.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mostrows@styx.uwaterloo.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030619122024.3d21c0ec.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 19 Jun 2003 12:20:24 -0700

   The /proc file operations for PPPOE is missing an owner entry.
   This means that if someone has /proc file open, it is still
   possible to unload the module.

Applied, thanks.

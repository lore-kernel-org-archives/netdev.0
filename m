From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPSEC support
Date: Sat, 22 Feb 2003 03:13:26 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030222.031326.103246837.davem@redhat.com>
References: <20030222202623.38d41d8a.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi-core@linux-ipv6.org, kunihiro@ipinfusion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org
In-Reply-To: <20030222202623.38d41d8a.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Kazunori Miyazawa <kazunori@miyazawa.org>
   Date: Sat, 22 Feb 2003 20:26:23 +0900

   I also moved the functions for ah, and esp.

I don't think this is so good idea...
   
   As a result of moving IPv6 IPsec functions to net/ipv4, it currently prevents to
   make IPv6 as a module.
   
This is one of the reasons why ah/esp ipv6 should stay under ipv6.

Nothing in xfrm routines really need to reference ipv6 module
functions, please eliminate this dependency.  Breaking ipv6 as module
is ok for temporary development, but eventually it must be solved.

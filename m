From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: 2.6.13-git3: build failure: sysctl_optmem_max
Date: Sat, 3 Sep 2005 11:27:56 +0100
Message-ID: <20050903112756.D29708@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750827AbVICK2D@vger.kernel.org>
To: Linux Kernel List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While trying to build a kernel with CONFIG_SYSCTL disabled, the following
error occurs:

  CC      net/ipv4/ip_sockglue.o
net/ipv4/ip_sockglue.c: In function `ip_setsockopt':
net/ipv4/ip_sockglue.c:622: error: `sysctl_optmem_max' undeclared (first use in
net/ipv4/ip_sockglue.c:622: error: (Each undeclared identifier is reported only
net/ipv4/ip_sockglue.c:622: error: for each function it appears in.)

It seems that sysctl_optmem_max is only available if CONFIG_SYSCTL is set.
However, ip_setsockopt makes unconditional usage of this variable.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core

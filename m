From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] don't allow CAP_NET_ADMIN to load non-netdev kernel
 modules
Date: Sun, 27 Feb 2011 15:19:12 -0800 (PST)
Message-ID: <20110227.151912.28823451.davem@davemloft.net>
References: <1298660879.2554.23.camel@bwh-desktop>
	<20110225.111606.115927805.davem@davemloft.net>
	<20110227114438.GA4317@albatros>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, eric.dumazet@gmail.com, therbert@google.com,
	xiaosuo@gmail.com, jesse@nicira.com, kees.cook@canonical.com,
	eugene@redhat.com, dan.j.rosenberg@gmail.com,
	akpm@linux-foundation.org
To: segoon@openwall.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110227114438.GA4317@albatros>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vasiliy Kulikov <segoon@openwall.com>
Date: Sun, 27 Feb 2011 14:44:38 +0300

> Then the things are still broken - a user has to update modprobe
> together with the kernel, otherwise the updated kernel would call
> "modprobe" with unsupported argument and even "sit0" wouldn't work.

The capability bits get passed on the modprobe command line.

The module loading system call in the kernel inspects the command
line looking for the argument, and uses it to validate the module
load by comparing the mask with the special ELF section.

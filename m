From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v3] net: ipv4: add IPPROTO_ICMP socket kind
Date: Fri, 13 May 2011 14:30:43 -0700
Message-ID: <m2wrhuxp8c.fsf@firstfloor.org>
References: <20110510.121550.112583080.davem@davemloft.net>
	<20110513200100.GA3875@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, solar@openwall.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	peak@argo.troja.mff.cuni.cz, kees.cook@canonical.com,
	dan.j.rosenberg@gmail.com, eugene@redhat.com, nelhage@ksplice.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, linux-man@vger.kernel.org
To: Vasiliy Kulikov <segoon@openwall.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110513200100.GA3875@albatros> (Vasiliy Kulikov's message of
	"Sat, 14 May 2011 00:01:00 +0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vasiliy Kulikov <segoon@openwall.com> writes:

> This patch adds IPPROTO_ICMP socket kind.  It makes it possible to send
> ICMP_ECHO messages and receive the corresponding ICMP_ECHOREPLY messages
> without any special privileges.  In other words, the patch makes it
> possible to implement setuid-less and CAP_NET_RAW-less /bin/ping.  In
> order not to increase the kernel's attack surface, the new functionality
> is disabled by default, but is enabled at bootup by supporting Linux
> distributions, optionally with restriction to a group or a group range
> (see below).

You'll need to do a manpage patch too. Otherwise noone will know how to use
it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

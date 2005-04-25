From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.4.30-pre3] net/{icmp,ipv6}.h: include net/snmp.h
Date: Sun, 24 Apr 2005 19:43:13 -0700
Message-ID: <20050424194313.2c466b8a.davem@davemloft.net>
References: <20050318212256.GB26112@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
In-Reply-To: <20050318212256.GB26112@lists.us.dell.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 15:22:56 -0600
Matt Domsch <Matt_Domsch@dell.com> wrote:

> Compiling linux-2.4.30-pre3 with FC4-test1 compiler gcc-4.0.0-0.32 on
> x86_64 fails because icmp_statistics[NR_CPUS*2] is declared as a sized
> array without struct icmp_mib having been defined, likewise
> ipv6_statistics[NR_CPUS*2] without struct ipv6_mib first defined.
> 
> Solution is to include <net/snmp.h> before declaring either array.

I don't think we're going to take gcc-4.0 build fixes for the 2.4.x
tree.  I think deep maintainence mode should really mean deep
maintainence mode, and that's what the 2.4.x tree is in right now.

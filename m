From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] TCP acts like it is always out of memory.
Date: Thu, 1 Jul 2004 14:04:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701140406.62dfbc2a.davem@redhat.com>
References: <32886.63.170.215.71.1088564087.squirrel@www.osdl.org>
	<20040629222751.392f0a82.davem@redhat.com>
	<20040630152750.2d01ca51@dell_ss3.pdx.osdl.net>
	<20040630153049.3ca25b76.davem@redhat.com>
	<20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040701133738.301b9e46@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 1 Jul 2004 13:37:38 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Current 2.6.7 tree acts as if it is alway under memory pressure because
> a recent change did a s/tcp_memory_pressure/tcp_prot.memory_pressure/.
> The problem is tcp_prot.memory_pressure is a pointer, so it is always non-zero!
> 
> Rather than using *tcp_prot.memory_pressure, just go back to looking at
> tcp_memory_pressure.

Hehe, applied thanks Stephen.

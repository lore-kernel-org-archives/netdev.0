From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 3/5] TCP Westwood+ support
Date: Sun, 20 Mar 2005 19:17:24 -0800
Message-ID: <20050320191724.72089c5a.akpm@osdl.org>
References: <20050318162412.189ccf9c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050318162412.189ccf9c@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
>
>  Add TCP Westwood+ support back in as a separate pluggable algorithm.
>  The mechanism and policy is unchanged from existing code.

net/built-in.o(.text+0x4b052): In function `tcp_westwood_info':
net/ipv4/tcp_westwood.c:307: undefined reference to `tcpdiag_put'

linux:/usr/src/25> grep WESTW .config
CONFIG_TCP_CONG_WESTWOOD=y
linux:/usr/src/25> grep TCPDIAG .config
CONFIG_IP_TCPDIAG=m
CONFIG_IP_TCPDIAG_IPV6=y

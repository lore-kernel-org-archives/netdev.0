From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 3/5] TCP Westwood+ support
Date: Sun, 20 Mar 2005 20:53:45 -0800
Message-ID: <20050320205345.13930cd8.akpm@osdl.org>
References: <20050318162412.189ccf9c@dxpl.pdx.osdl.net>
	<20050320191724.72089c5a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: shemminger@osdl.org, davem@davemloft.net, netdev@oss.sgi.com
In-Reply-To: <20050320191724.72089c5a.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Stephen Hemminger <shemminger@osdl.org> wrote:
>  >
>  >  Add TCP Westwood+ support back in as a separate pluggable algorithm.
>  >  The mechanism and policy is unchanged from existing code.
> 
>  net/built-in.o(.text+0x4b052): In function `tcp_westwood_info':
>  net/ipv4/tcp_westwood.c:307: undefined reference to `tcpdiag_put'

I got bored of this, so I fixed it.

--- 25-sparc64/net/ipv4/Kconfig~tcp-westwood-support-kconfig-fix	2005-03-20 20:51:18.000000000 -0800
+++ 25-sparc64-akpm/net/ipv4/Kconfig	2005-03-20 20:52:02.000000000 -0800
@@ -426,6 +426,7 @@ config TCP_CONG_BIC
 
 config TCP_CONG_WESTWOOD
 	tristate "TCP Westwood+"
+	select IP_TCPDIAG
 	default y
 	---help---
 	TCP Westwood+ is a sender-side only modification of the TCP Reno
_

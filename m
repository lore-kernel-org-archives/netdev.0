From: Stephen Hemminger <shemminger@osdl.org>
Subject: 2.6.12-rc4-tcp2
Date: Wed, 11 May 2005 16:49:39 -0700
Message-ID: <20050511164939.1ec95f2f@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, Baruch Even <baruch@ev-en.org>,
        Daniele Lacamera <mlists@danielinux.net>,
        "Angelo Dell'Aera"
 <buffer@antifork.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

http://developer.osdl.org/shemminger/patches/2.6.12-rc4-tcp2

Patches that should probably go in 2.6.13. 
Note: Westwood and Hybla need more debugging and don't seem
to work correctly.

# stuff to cleanup netif_rx
fastroute-stats-remove.diff
no-congestion.diff
no-throttle.diff
bigger-backlog.diff
fix-weightp.diff

tso-reloaded.patch

# TCP congestion infrastructure
tcp_infra.patches
tcp_bic.patch
westwood.patch
hstcp.patch
hybla.patch
vegas.patch
h-tcp.patch

# Rearrange sk_buff to make room for bigger cb[]
# This allows adding ptr for SACK improvement without
# more memory
skbuff-del-security.patch

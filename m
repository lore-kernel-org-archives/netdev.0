From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] 1/1 net: packet: Keep 802.1Q VLAN tag in packet on SOCK_DGRAM
 socket - resend
Date: Mon, 04 Jan 2010 14:52:18 +0100
Message-ID: <4B41F292.8080908@trash.net>
References: <001801ca8d1d$90c68de0$b253a9a0$@name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: uaca@alumni.uv.es, johann.baudy@gnu-log.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Milan Dadok <milan@dadok.name>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753358Ab0ADNwW@vger.kernel.org>
In-Reply-To: <001801ca8d1d$90c68de0$b253a9a0$@name>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[please don't remove the mailing list from CC]

Milan Dadok wrote:
> Keep 802.1Q VLAN tag on non HW vlan accelerated network card received to SOCK_DGRAM socket.

Quoting from Documentation/networking/packet_mmap.txt:

fd= socket(PF_PACKET, mode, htons(ETH_P_ALL))

where mode is SOCK_RAW for the raw interface were link level
information can be captured or SOCK_DGRAM for the cooked
interface where link level information capture is not
supported and a link level pseudo-header is provided
by the kernel.

So not including the link layer header for SOCK_DGRAM sockets
seems to be the intended behaviour.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: UDP counter doesn't increase
Date: Fri, 20 Feb 2004 09:46:12 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220094612.026c62da.davem@redhat.com>
References: <20040219110035.2e1c15b4%hibi665@oki.com>
	<20040219.112557.102901782.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: hibi665@oki.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040219.112557.102901782.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 11:25:57 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20040219110035.2e1c15b4%hibi665@oki.com> (at Thu, 19 Feb 2004 11:00:35 +0900), Takashi Hibi <hibi665@oki.com> says:
> 
> > UdpInDatagram in /proc/net/snmp6 doen't increase when IPv6 multicast 
> > UDP packets are received.
> > sock_queue_rcv_skb() is called directly in udpv6_mcast_deliver. I think that
> > udpv6_queue_rcv_skb() should be called instead of sock_queue_rcv_skb()
> > as IPv4.
> 
> Okay, here's the patch.

Applied, thanks everyone.

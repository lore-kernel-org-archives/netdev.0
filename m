From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Tue, 10 Feb 2004 03:00:24 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0402100251380.1251@u.domain.uli>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
 <20040209140853.69ab8bea.davem@redhat.com> <Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
 <20040209151053.1f63937a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209151053.1f63937a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	May be this will be something like final patch, I removed
the games with skb->dst because there are cases where SNAT can take
place after input routing, etc:

http://www.ssi.bg/~ja/arp_announce-2.6.2-3.diff

	If you like it in this way you can apply now or after
some days or to delay it if we want to combine it with other
device flags or changes.

Regards

--
Julian Anastasov <ja@ssi.bg>

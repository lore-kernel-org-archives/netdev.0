From: "David S. Miller" <davem@redhat.com>
Subject: Re: Restrict local IP announcements in ARP requests
Date: Tue, 17 Feb 2004 19:07:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040217190753.238c5ae0.davem@redhat.com>
References: <Pine.LNX.4.58.0402081149001.6268@u.domain.uli>
	<20040209140853.69ab8bea.davem@redhat.com>
	<Pine.LNX.4.58.0402100049470.1251@u.domain.uli>
	<20040209151053.1f63937a.davem@redhat.com>
	<Pine.LNX.4.58.0402100154010.1251@u.domain.uli>
	<20040211202251.7b05102c.davem@redhat.com>
	<Pine.LNX.4.58.0402151153450.1129@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0402151153450.1129@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 15 Feb 2004 12:04:59 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	The same patch is also here:
> 
> http://www.ssi.bg/~ja/tmp/arp_ignore-2.6.2-arp-1.diff

I've applied this, the patch is a NOP unless people actually change
the sysctl value from the default.

This allows me to just put it in now, and we can refine the details of
the new behavior next.

Please make me a 2.4.x version of this patch (again with the other ARP
thing applied already).

Thanks Julian.

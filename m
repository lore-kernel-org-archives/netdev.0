From: "David S. Miller" <davem@redhat.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 13:45:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040209134551.3bd533a2.davem@redhat.com>
References: <Pine.LNX.4.58.0402082234110.6268@u.domain.uli>
	<20040209121926.6f016ebf.davem@redhat.com>
	<4027FE27.9020102@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4027FE27.9020102@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 09 Feb 2004 13:39:51 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Arp requests are always broadcasts, so promisc changes nothing,
> right?

Unicast probes are possible.

If it is broadcast/multicast then pkt_type will be PACKET_{BROAD,MULTI}CAST.

The existing ipv4 proxy-arp code is saying (as I read it) to not delay the
response if this is a unicast probe.  This is one of the behaviors that
Julian is modifying slightly.

For everyone's edification, when looking at changes Julian is suggesting, realize
that his interests lie in IPVS like applications, so consider the corner case
situations that such setups might be interested in and you'll see clearly the
impetus for all of his ARP change proposals :-)

From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and
 code
Date: Wed, 11 Aug 2004 13:30:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040811133043.455c81fa.davem@redhat.com>
References: <20040810230144.2a68914b.davem@redhat.com>
	<OF94FC19D3.2EA706DF-ON88256EED.006875F7-88256EED.006980E7@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OF94FC19D3.2EA706DF-ON88256EED.006875F7-88256EED.006980E7@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Aug 2004 13:14:19 -0600
David Stevens <dlstevens@us.ibm.com> wrote:

> raw sockets predate VJ contributions by many years and are
> typically used by protocols not in the kernel. The original "ping"
> used raw sockets, as well as routing protocols like BGP and RIP
> which are directly encapsulated in IP, without a separate transport
> protocol. The original traceroute I believe used UDP and just set
> the TTL-- I don't believe it used raw sockets at all. Don't know what
> the current versions do; haven't looked in a while.

"ping" does not use the hdrinclude feature.

> And IPv6 does support raw sockets; it just doesn't let you
> generate bad checksums and some header fields, I expect
> to make it harder to write attack software.

So like I said, raw without the hdrinclude feature.

From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Fri, 25 Jul 2003 11:46:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030725114634.73dc9e8d.davem@redhat.com>
References: <200307241728270476.0031BAB0@192.168.128.16>
	<Pine.LNX.4.44.0307241849341.2177-100000@l>
	<20030724091007.68923845.davem@redhat.com>
	<200307252024190066.051F80CE@192.168.128.16>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Carlos Velasco" <carlosev@newipnet.com>
In-Reply-To: <200307252024190066.051F80CE@192.168.128.16>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 25 Jul 2003 20:24:19 +0200
"Carlos Velasco" <carlosev@newipnet.com> wrote:

> On 24/07/2003 at 9:10 David S. Miller wrote:
> 
> >The hidden patch is not necessary with current kernels and arpfilter.
> 
> arp_filter doesn't work.

This is impossible, hidden is a subset of what arpfilter can do.

arpfilter is a netfilter module that can block ARP packets
at any point in the networking stack, at your choosing.

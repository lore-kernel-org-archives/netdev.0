From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] ax25 & netrom fixes for 2.6
Date: Tue, 12 Aug 2003 13:56:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812135655.7334887b.shemminger@osdl.org>
References: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, ralf@linux-mips.org, davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeroen Vreeken <pe1rxq@amsat.org>
In-Reply-To: <20030812194653.A28977@jeroen.pe1rxq.ampr.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

It looks like af_x25 is advertising itself as a new style protocol, yet if
I walk the receive path:
	ax25_kiss_rcv -> ax25_rcv -> ax25_addr_parse
there is no place that checks that the address portion of the buffer isn't fragmented
into a non_linear skb.

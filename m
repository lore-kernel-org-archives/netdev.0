From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix outstanding ref's preventing ether driver unload
Date: Wed, 24 Dec 2003 19:14:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031224191425.7b12f555.davem@redhat.com>
References: <OFB4EC53DF.8138874D-ON88256DF9.0082A560@us.ibm.com>
	<20031223142931.703d5c88.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031223142931.703d5c88.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Dec 2003 14:29:31 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Patch against 2.6.0 to fix the problem of being unable to load the
> ethernet driver because of reference's still being held.  The
> problem reference's are from IPV6 network discovery packets that get
> captured by the af_packet protocol and queued onto a socket queue
> (which may never drain).  The route dst entries in the skbuff get
> clone'd and won't be freed until the socket read.

Ok, I've applied this patch, it's the best solution at this time.

Thanks.

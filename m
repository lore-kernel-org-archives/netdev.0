From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TCP-MD5 support
Date: Thu, 21 Oct 2004 15:51:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041021155109.204e4f68.davem@davemloft.net>
References: <417837D4.1020402@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Tomt <andre@tomt.net>
In-Reply-To: <417837D4.1020402@tomt.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Oct 2004 00:27:32 +0200
Andre Tomt <andre@tomt.net> wrote:

> How is this moving along? Last time I heard around 2.6.7 sometime it was 
> beeing cleaned up for inclusion in mainline.

Yeah, I have a tree at:

	bk://kernel.bkbits.net/davem/tcp-2.6

that Yoshifuji and myself were working on.  It needs two
pieces of work which I'll do soon:

1) Remove the older API, the newer AF-agnostic one is
   the only one we should provide

2) Merge up with current 2.6.x

Then it'll be ready to merge to Linus.

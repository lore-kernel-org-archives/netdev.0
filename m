From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] Silencing needless printk in socket.c
Date: Thu, 2 Oct 2003 01:48:38 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002014838.0c790cda.davem@redhat.com>
References: <Pine.LNX.4.58.0310011429190.1125@morpheus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Burton Windle <bwindle@fint.org>
In-Reply-To: <Pine.LNX.4.58.0310011429190.1125@morpheus>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 1 Oct 2003 14:41:09 -0400 (EDT)
Burton Windle <bwindle@fint.org> wrote:

> Would anyone object to a patch that wraps the printk in
> linux/net/socket.c:1897 in a 'if debug'?
> 
> This first appeared around 2.6.0-test5; the output may be helpful to a
> developer, but I don't think it is needed in the normal dmesg.

Yes it is needed, and since in the same changes that _ADDED_
this new printk I _REMOVED_ all the numerous per-protocol printks
that were printed out.

Less stuff is printed out now than before, and now this is the
only indication that a particular protocol family got registered
or unregistered successfully.

We're not removing this.  This is especially the case beause people
like you didn't complain at all when we used to get 4 or 5 lines of
printk messages for each of these protocols when they started up or
shut down.

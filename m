From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv4 ARP hash algorithm has poor distribution
Date: Mon, 15 Mar 2004 13:44:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040315134458.57250953.davem@redhat.com>
References: <200403151132.31368.timg@tpi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: timg@tpi.com
In-Reply-To: <200403151132.31368.timg@tpi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If you're going to change the hash algorithm, just use the linux/jhash.h stuff.
I'm sure it will give stunning hash chain distribution as it does for everything
else we've used it for.

From: Andi Kleen <ak@suse.de>
Subject: Re: Linux Oops on skb_release_data()
Date: Tue, 8 Jun 2004 14:53:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040608125333.GA1271@wotan.suse.de>
References: <FD52892BD296D71183B400065BFCB6900AF770DE@il02exm12>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lewis Adam-CAL022 <Adam.Lewis@motorola.com>
Content-Disposition: inline
In-Reply-To: <FD52892BD296D71183B400065BFCB6900AF770DE@il02exm12>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Any ideas?

Most likely you're corrupting memory somewhere, in particular overwrite the boundaries
of the your skb data area. I would suggest to build the kernel with slab debugging
and check all your skb->data accesses.

-Andi

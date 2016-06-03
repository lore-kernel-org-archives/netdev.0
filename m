From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC v7 3/5] skb_array: array based FIFO for skbs
Date: Fri, 3 Jun 2016 16:04:09 +0300
Message-ID: <20160603160351-mutt-send-email-mst@redhat.com>
References: <1464883305-32368-1-git-send-email-mst@redhat.com>
 <1464883305-32368-4-git-send-email-mst@redhat.com>
 <20160603145839.2de0ead9@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160603145839.2de0ead9@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 03, 2016 at 02:58:39PM +0200, Jesper Dangaard Brouer wrote:
> 
> On Thu, 2 Jun 2016 19:08:26 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> > A simple array based FIFO of pointers.  Intended for net stack so uses
> > skbs for type safety. Implemented as a set of wrappers around ptr_array.
>                                                                 ^^^^^^^^^
> It is called "ptr_ring" not "ptr_array".


Thanks!
Jason, could you please tweak this when you repost?

> -- 
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer

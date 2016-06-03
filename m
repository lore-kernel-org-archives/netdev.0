From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH RFC v7 3/5] skb_array: array based FIFO for skbs
Date: Fri, 3 Jun 2016 14:58:39 +0200
Message-ID: <20160603145839.2de0ead9@redhat.com>
References: <1464883305-32368-1-git-send-email-mst@redhat.com>
	<1464883305-32368-4-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464883305-32368-4-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2 Jun 2016 19:08:26 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:

> A simple array based FIFO of pointers.  Intended for net stack so uses
> skbs for type safety. Implemented as a set of wrappers around ptr_array.
                                                                ^^^^^^^^^
It is called "ptr_ring" not "ptr_array".

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

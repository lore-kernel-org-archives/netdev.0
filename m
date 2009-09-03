From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] slub: fix slab_pad_check() and SLAB_DESTROY_BY_RCU
Date: Thu, 3 Sep 2009 17:05:30 +0300
Message-ID: <84144f020909030705x7909cf07w7ea0d3662a66c5cc@mail.gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>
	 <4A896324.3040104@trash.net>
	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
	 <4A9EEF07.5070800@gmail.com>
	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
	 <4A9F1620.2080105@gmail.com>
	 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
	 <4A9F7283.1090306@gmail.com>
	 <84144f020909030051u6cf6ae01he25c268f718ff3af@mail.gmail.com>
	 <alpine.DEB.1.10.0909031246010.27903@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0909031246010.27903@V090114053VZO-1>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christoph,

On Thu, 3 Sep 2009, Pekka Enberg wrote:
>> Oh, sure, the fix looks sane to me. It's just that I am a complete
>> coward when it comes to merging RCU related patches so I always try to
>> fish an Acked-by from Paul or Christoph ;).

On Thu, Sep 3, 2009 at 8:50 PM, Christoph
Lameter<cl@linux-foundation.org> wrote:
> I am fine with acking the poison piece.

Ok.

On Thu, Sep 3, 2009 at 8:50 PM, Christoph
Lameter<cl@linux-foundation.org> wrote:
> I did not ack the patch that added rcu to kmem_cache_destroy() and I
> likely wont ack that piece either.

Right. I didn't remember that I merged that over your NAK but I don't
share your view that kmem_cache_destroy() callers should do
rcu_barrier() or whatever is necessary if we can do it from
kmem_cache_destroy(). So I am happy to take both changes but I would
appreciate them being split into two separate patches.

                        Pekka

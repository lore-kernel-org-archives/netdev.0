From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] slub: fix slab_pad_check()
Date: Thu, 3 Sep 2009 22:34:38 +0300
Message-ID: <84144f020909031234y764ebad2t1be8bf28dca25ace@mail.gmail.com>
References: <c4e36d110908110542l3de51aaepcbd62c84b9848f2b@mail.gmail.com>
	 <4A896324.3040104@trash.net>
	 <c4e36d110909021445l5f44183es9e338437dfbbd195@mail.gmail.com>
	 <4A9EEF07.5070800@gmail.com>
	 <c4e36d110909021531v324a9ce2x3ff2c93b7c5a57de@mail.gmail.com>
	 <4A9F1620.2080105@gmail.com>
	 <84144f020909022331x2b275aa5n428f88670e0ae8bc@mail.gmail.com>
	 <4A9F7283.1090306@gmail.com>
	 <alpine.DEB.1.10.0909031244230.27903@V090114053VZO-1>
	 <4A9FCDC6.3060003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Christoph Lameter <cl@linux-foundation.org>,
	Zdenek Kabelac <zdenek.kabelac@gmail.com>,
	Patrick McHardy <kaber@trash.net>, Robin Holt <holt@sgi.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	paulmck@linux.vnet.ibm.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4A9FCDC6.3060003@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2009 at 5:08 PM, Eric Dumazet<eric.dumazet@gmail.com> wrote:
> Sure, here is the poison thing
>
> [PATCH] slub: fix slab_pad_check()
>
> When SLAB_POISON is used and slab_pad_check() finds an overwrite of the
> slab padding, we call restore_bytes() on the whole slab, not only
> on the padding.
>
> Reported-by: Zdenek Kabelac <zdenek.kabelac@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks!

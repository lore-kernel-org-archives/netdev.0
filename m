From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 1/2] virtio-net: Verify page list size before fitting
 into skb
Date: Mon, 3 Oct 2011 20:42:57 +0200
Message-ID: <20111003184257.GB22427@redhat.com>
References: <1317220855-9352-1-git-send-email-levinsasha928@gmail.com>
 <20111003.141951.1122469843900651595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: levinsasha928@gmail.com, linux-kernel@vger.kernel.org,
	rusty@rustcorp.com.au, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111003.141951.1122469843900651595.davem@davemloft.net>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 03, 2011 at 02:19:51PM -0400, David Miller wrote:
> From: Sasha Levin <levinsasha928@gmail.com>
> Date: Wed, 28 Sep 2011 17:40:54 +0300
> 
> > This patch verifies that the length of a buffer stored in a linked list
> > of pages is small enough to fit into a skb.
> > 
> > If the size is larger than a max size of a skb, it means that we shouldn't
> > go ahead building skbs anyway since we won't be able to send the buffer as
> > the user requested.
> > 
> > Cc: Rusty Russell <rusty@rustcorp.com.au>
> > Cc: "Michael S. Tsirkin" <mst@redhat.com>
> > Cc: virtualization@lists.linux-foundation.org
> > Cc: netdev@vger.kernel.org
> > Cc: kvm@vger.kernel.org
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> 
> Michael, tell me what's happening with these two virtio-net bug fixes.
> 
> Thanks.

Thanks for the reminder.
They are more enhancements than bugfixes, in that both help debug buggy
hypervisors. So net-next material.
Patch 1 is ok patch 2 would benefit from a slightly clearer comment.

-- 
MST

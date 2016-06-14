From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 4/5] ptr_ring: resize support
Date: Tue, 14 Jun 2016 14:04:28 +0200
Message-ID: <20160614140428.7fb2bd94@redhat.com>
References: <1465851234-13558-1-git-send-email-mst@redhat.com>
	<20160613235445-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750808AbcFNMEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 08:04:34 -0400
In-Reply-To: <20160613235445-mutt-send-email-mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jun 2016 23:54:45 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> This adds ring resize support. Seems to be necessary as
> users such as tun allow userspace control over queue size.
> 
> If resize is used, this costs us ability to peek at queue without
> consumer lock - should not be a big deal as peek and consumer are
> usually run on the same CPU.
> 
> If ring is made bigger, ring contents is preserved.  If ring is made
> smaller, extra pointers are passed to an optional destructor callback.
> 
> Cleanup function also gains destructor callback such that
> all pointers in queue can be cleaned up.
> 
> This changes some APIs but we don't have any users yet,
> so it won't break bisect.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

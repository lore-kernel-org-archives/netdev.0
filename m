From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio: put last seen used index into ring itself
Date: Tue, 18 May 2010 17:11:07 +0930
Message-ID: <201005181711.08128.rusty@rustcorp.com.au>
References: <20100518004744.GA21359@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jpirko@redhat.com>, Shirley Ma <xma@us.ibm.com>,
	Amit Shah <amit.shah@redhat.com>,
	Mark McLoughlin <markmc@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, quintela@redhat.com,
	alex.williamson@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45892 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757316Ab0EROUR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 10:20:17 -0400
In-Reply-To: <20100518004744.GA21359@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 May 2010 10:17:44 am Michael S. Tsirkin wrote:
> Generally, the Host end of the virtio ring doesn't need to see where
> Guest is up to in consuming the ring.  However, to completely understand
> what's going on from the outside, this information must be exposed.
> For example, host can reduce the number of interrupts by detecting
> that the guest is currently handling previous buffers.

Thanks applied.

Cheers,
Rusty.

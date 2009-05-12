From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
Date: Tue, 12 May 2009 23:53:53 +0930
Message-ID: <200905122353.54424.rusty@rustcorp.com.au>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com> <200905041149.00724.rusty@rustcorp.com.au> <1242061838.25337.8.camel@blaa>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dlaor@redhat.com, netdev@vger.kernel.org,
	Dor Laor <dor@redhat.com>, Avi Kivity <avi@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:52526 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbZELOYH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 10:24:07 -0400
In-Reply-To: <1242061838.25337.8.camel@blaa>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 May 2009 02:40:38 am Mark McLoughlin wrote:
> > Blocked from doing the simpler thing, we've decided to go with a layer
> > of indirection.  But the patch is simple and clean, so there's nothing
> > fundamental to object to.
>
> Still have one FIXME in the patch worth looking at - at what point
> should we use an indirect entry rather than consuming N entries?

OK, I've applied these as is.  I'm doing some virtio net benchmarking (under 
lguest); I'll see if I can get a reasonable figure.  I don't think there's an 
obvious right answer; it depends how many more packets are coming as well as 
how many descriptors each will use.

Thanks,
Rusty.

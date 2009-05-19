From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio: indirect ring entries (VIRTIO_RING_F_INDIRECT_DESC)
Date: Tue, 19 May 2009 17:45:00 +0930
Message-ID: <200905191745.00563.rusty@rustcorp.com.au>
References: <1229620222-22216-1-git-send-email-markmc@redhat.com> <200905172346.14498.rusty@rustcorp.com.au> <4A1027C3.3080109@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>, dlaor@redhat.com,
	netdev@vger.kernel.org, Dor Laor <dor@redhat.com>,
	virtualization@lists.linux-foundation.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35314 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750778AbZESIPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2009 04:15:10 -0400
In-Reply-To: <4A1027C3.3080109@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 May 2009 12:35:39 am Avi Kivity wrote:
> Rusty Russell wrote:
> > No, it's true for block.  It has output parts, so we should reduce
> > threshold when it's full.  Network recvq is an example which should
> > reduce threshold when it's empty.
>
> You mean the header that contains the sector number?  It's a little
> incidental, but I guess it works.

Yes, the one which breaks is randomness.  You really do just throw buffers with 
no metadata in them and the request is implied. If/when we care, we can add a 
hint flag.

Cheers,
Rusty.

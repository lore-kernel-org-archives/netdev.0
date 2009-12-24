From: Amit Shah <amit.shah@redhat.com>
Subject: Re: [PATCH 1/2] virtio: Add detach unused buffer from vring
Date: Thu, 24 Dec 2009 19:05:44 +0530
Message-ID: <20091224133544.GA2855@amit-x200.redhat.com>
References: <1261122090.4148.24.camel@localhost.localdomain> <1261122230.4148.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28042 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbZLXNgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Dec 2009 08:36:48 -0500
Content-Disposition: inline
In-Reply-To: <1261122230.4148.26.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (Thu) Dec 17 2009 [23:43:50], Shirley Ma wrote:
> There's currently no way for a virtio driver to ask for unused
> buffers, so it has to keep a list itself to reclaim them at shutdown.
> This is redundant, since virtio_ring stores that information.  So
> add a new hook to do this: virtio_net will be the first user.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>

Acked-By: Amit Shah <amit.shah@redhat.com>

		Amit

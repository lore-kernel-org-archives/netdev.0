From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 1/4] Add a new API to virtio-pci
Date: Thu, 9 Sep 2010 13:19:39 +0930
Message-ID: <201009091319.40274.rusty@rustcorp.com.au>
References: <20100908072859.23769.97363.sendpatchset@krkumar2.in.ibm.com> <20100908072905.23769.10732.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, anthony@codemonkey.ws,
	kvm@vger.kernel.org, mst@redhat.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:51275 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751168Ab0IIDtm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Sep 2010 23:49:42 -0400
In-Reply-To: <20100908072905.23769.10732.sendpatchset@krkumar2.in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Sep 2010 04:59:05 pm Krishna Kumar wrote:
> Add virtio_get_queue_index() to get the queue index of a
> vq.  This is needed by the cb handler to locate the queue
> that should be processed.

This seems a bit weird.  I mean, the driver used vdev->config->find_vqs
to find the queues, which returns them (in order).  So, can't you put this
into your struct send_queue?

Also, why define VIRTIO_MAX_TXQS?  If the driver can't handle all of them,
it should simply not use them...

Thanks!
Rusty.

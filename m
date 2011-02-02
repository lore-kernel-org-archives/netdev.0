From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: Network performance with small packets
Date: Wed, 2 Feb 2011 08:29:50 +0200
Message-ID: <20110202062950.GD3818@redhat.com>
References: <1296594585.26937.817.camel@localhost.localdomain>
 <20110201212411.GD30770@redhat.com>
 <1296595955.26937.822.camel@localhost.localdomain>
 <20110201214211.GB31105@redhat.com>
 <1296597185.26937.829.camel@localhost.localdomain>
 <20110201215603.GA31348@redhat.com>
 <1296601197.26937.833.camel@localhost.localdomain>
 <20110202044002.GB3818@redhat.com>
 <1296626748.26937.852.camel@localhost.localdomain>
 <1296627549.26937.856.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Steve Dobbelstein <steved@us.ibm.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	mashirle@linux.vnet.ibm.com, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425Ab1BBGaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Feb 2011 01:30:07 -0500
Content-Disposition: inline
In-Reply-To: <1296627549.26937.856.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 01, 2011 at 10:19:09PM -0800, Shirley Ma wrote:
> On Tue, 2011-02-01 at 22:05 -0800, Shirley Ma wrote:
> > 
> > The way I am changing is only when netif queue has stopped, then we
> > start to count num_free descriptors to send the signal to wake netif
> > queue. 
> 
> I forgot to mention, the code change I am making is in guest kernel, in
> xmit call back only wake up the queue when it's stopped && num_free >=
> 1/2 *vq->num, I add a new API in virtio_ring.

Interesting. Yes, I agree an API extension would be helpful. However,
wouldn't just the signaling reduction be enough, without guest changes?

> However vhost signaling reduction is needed as well. The patch I
> submitted a while ago showed both CPUs and BW improvement.
> 
> Thanks
> Shirley

Which patch was that?

-- 
MST

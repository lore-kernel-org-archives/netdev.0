From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: Defer skb allocation in receive path
Date: Mon, 04 Jan 2010 13:25:44 -0800
Message-ID: <1262640344.18773.2.camel@localhost.localdomain>
References: <1261122090.4148.24.camel@localhost.localdomain>
	 <1261122289.4148.27.camel@localhost.localdomain>
	 <20091224133749.GB2855@amit-x200.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Amit Shah <amit.shah@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49037 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752260Ab0ADVLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 16:11:30 -0500
In-Reply-To: <20091224133749.GB2855@amit-x200.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Amit,

Sorry for late response. I am just back from vacation.

On Thu, 2009-12-24 at 19:07 +0530, Amit Shah wrote:
> > +static void free_unused_bufs(struct virtnet_info *vi)
> > +{
> > +     void *buf;
> > +     while (vi->num) {
> > +             buf = vi->rvq->vq_ops->detach_unused_buf(vi->rvq);
> > +             if (!buf)
> > +                     continue;
> 
> Do you mean 'break' here?

Nope, it means break since the buffer usage is not sorted by descriptors
from my understanding. It breaks when vi->num reaches 0.

Thanks
Shirley


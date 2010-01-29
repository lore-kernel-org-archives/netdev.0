From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio_net: Defer skb allocation in receive path
Date: Fri, 29 Jan 2010 16:05:54 +0200
Message-ID: <20100129140553.GA4413@redhat.com>
References: <1262640344.18773.2.camel@localhost.localdomain> <20100104211454.GB21488@redhat.com> <1263236965.11949.1.camel@localhost.localdomain> <1263416018.29594.1.camel@localhost.localdomain> <20100113205750.GD21445@redhat.com> <1263418421.29594.3.camel@localhost.localdomain> <20100113213736.GF21445@redhat.com> <1263421428.29594.5.camel@localhost.localdomain> <20100113224804.GD21686@redhat.com> <1263429475.29594.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Shah <amit.shah@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27702 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078Ab0A2OJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jan 2010 09:09:59 -0500
Content-Disposition: inline
In-Reply-To: <1263429475.29594.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2010 at 04:37:55PM -0800, Shirley Ma wrote:
> On Thu, 2010-01-14 at 00:48 +0200, Michael S. Tsirkin wrote:
> > On Wed, Jan 13, 2010 at 02:23:48PM -0800, Shirley Ma wrote:
> > > On Wed, 2010-01-13 at 23:37 +0200, Michael S. Tsirkin wrote:
> > > > Yes, separate patch is best.
> > > 
> > > The send side patch is done, I will submit it when this patch has
> > > been reviewed. :)
> > 
> > 
> > Hey, why wait :)
> > 
> 
> Because: the send side patch is built on top of this patch and uses
> free_unused_bufs() func.
> 
> Thanks
> Shirley

Now that's in, how does the send patch look?

-- 
MST

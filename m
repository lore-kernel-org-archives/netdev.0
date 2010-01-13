From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v2 2/2] virtio_net: Defer skb allocation in receive path
Date: Wed, 13 Jan 2010 23:37:36 +0200
Message-ID: <20100113213736.GF21445@redhat.com>
References: <1261122090.4148.24.camel@localhost.localdomain> <1261122289.4148.27.camel@localhost.localdomain> <20091224133749.GB2855@amit-x200.redhat.com> <1262640344.18773.2.camel@localhost.localdomain> <20100104211454.GB21488@redhat.com> <1263236965.11949.1.camel@localhost.localdomain> <1263416018.29594.1.camel@localhost.localdomain> <20100113205750.GD21445@redhat.com> <1263418421.29594.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amit Shah <amit.shah@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822Ab0AMVkh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jan 2010 16:40:37 -0500
Content-Disposition: inline
In-Reply-To: <1263418421.29594.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 13, 2010 at 01:33:41PM -0800, Shirley Ma wrote:
> On Wed, 2010-01-13 at 22:57 +0200, Michael S. Tsirkin wrote:
> > How hard is it to get rid of send queue, btw?
> 
> Pretty straight forward. I prefer a separate patch for send side so I
> didn't include it in this patch.
> 
> Thanks
> Shirley

Yes, separate patch is best.

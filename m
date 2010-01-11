From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: Defer skb allocation in receive path
Date: Mon, 11 Jan 2010 11:09:25 -0800
Message-ID: <1263236965.11949.1.camel@localhost.localdomain>
References: <1261122090.4148.24.camel@localhost.localdomain>
	 <1261122289.4148.27.camel@localhost.localdomain>
	 <20091224133749.GB2855@amit-x200.redhat.com>
	 <1262640344.18773.2.camel@localhost.localdomain>
	 <20100104211454.GB21488@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amit Shah <amit.shah@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Avi Kivity <avi@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:48706 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753189Ab0AKTJ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 14:09:29 -0500
In-Reply-To: <20100104211454.GB21488@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-04 at 23:14 +0200, Michael S. Tsirkin wrote:
> so it will never return NULL unless no more buffers?  breaking here ad
> BUG_ON(vi->num) as Amit suggests seems cleaner than looping forever if
> there's a bug. 

Agree. I will change to break as Amit suggested and put BUG_ON and
resubmit the patch.

Thanks
Shirley


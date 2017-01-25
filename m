From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net PATCH v5 1/6] virtio_net: use dev_kfree_skb for small
 buffer XDP receive
Date: Wed, 25 Jan 2017 16:47:57 +0200
Message-ID: <20170125164534-mutt-send-email-mst@kernel.org>
References: <20170117221443.20280.62546.stgit@john-Precision-Tower-5810>
 <20170117221950.20280.39496.stgit@john-Precision-Tower-5810>
 <20170123230809-mutt-send-email-mst@kernel.org>
 <20170124.144328.2195698124358175034.davem@davemloft.net>
 <20170124215412-mutt-send-email-mst@kernel.org>
 <a129524e-c4af-5c67-5397-dec992c70fa1@redhat.com>
 <20170125051810-mutt-send-email-mst@kernel.org>
 <58882355.70307@gmail.com>
 <46915782-1c3f-04a9-ae0a-84e5f805af1f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35536 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750748AbdAYOr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 09:47:58 -0500
Content-Disposition: inline
In-Reply-To: <46915782-1c3f-04a9-ae0a-84e5f805af1f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 25, 2017 at 01:46:46PM +0800, Jason Wang wrote:
> > Then it would seem like a good thing to have another user of these paths and
> > find the bugs versus letting them sit there for some poor folks who do use
> > sleep/hybernate.
> > 
> 
> Yes, and uncovering hypervisor bugs now is better than uncovering it in the
> future.
> 
> Thanks

Not really, all the uncovering should happen in -next or early rc.
Right now we need to fix what has been uncovered so far.

-- 
MST

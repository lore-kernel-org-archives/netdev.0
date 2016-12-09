From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH v5 0/6] XDP for virtio_net
Date: Fri, 9 Dec 2016 05:01:30 +0200
Message-ID: <20161209045537-mutt-send-email-mst@kernel.org>
References: <20161208.141702.1346950420275854265.davem@davemloft.net>
 <20161208193814.GA1954@ast-mbp.thefacebook.com>
 <5849C68F.7080707@gmail.com>
 <20161208.171602.544798927904408724.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, shm@cumulusnetworks.com, tgraf@suug.ch,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43588 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752110AbcLIDBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 22:01:40 -0500
Content-Disposition: inline
In-Reply-To: <20161208.171602.544798927904408724.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 05:16:02PM -0500, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Thu, 8 Dec 2016 12:46:07 -0800
> 
> > On 16-12-08 11:38 AM, Alexei Starovoitov wrote:
> >> On Thu, Dec 08, 2016 at 02:17:02PM -0500, David Miller wrote:
> >>> From: John Fastabend <john.fastabend@gmail.com>
> >>> Date: Wed, 07 Dec 2016 12:10:47 -0800
> >>>
> >>>> This implements virtio_net for the mergeable buffers and big_packet
> >>>> modes. I tested this with vhost_net running on qemu and did not see
> >>>> any issues. For testing num_buf > 1 I added a hack to vhost driver
> >>>> to only but 100 bytes per buffer.
> >>>  ...
> >>>
> >>> So where are we with this?
> > 
> > There is one possible issue with a hang that Michael pointed out. I can
> > either spin a v6 or if you pull this v5 series in I can post a bugfix
> > for it. I am not seeing the issue in practice XDP virtio has been up
> > and running on my box here for days without issue.
> 
> If that's the case then please spin a v6 and I'll apply it.

I think 1/6 should be reworked, disabling/enabling GUEST_TSO
transparently without touching the LRO flag, and without adding
NDO callback.

-- 
MST

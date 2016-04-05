From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Tue, 5 Apr 2016 10:19:40 +0200
Message-ID: <20160405101940.74a10ba2@redhat.com>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
	<1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
	<CALx6S35N1W32e9fvAmEbPdZk1PK2eNUgd0uU7pteMkBoHUd36g@mail.gmail.com>
	<20160403070221.GF21980@gmail.com>
	<20160404220714.GB9972@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>, brouer@redhat.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38248 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757456AbcDEITq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:19:46 -0400
In-Reply-To: <20160404220714.GB9972@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 5 Apr 2016 00:07:14 +0200 Thomas Graf <tgraf@suug.ch> wrote:

> On 04/03/16 at 12:02am, Brenden Blanco wrote:
> > On Sat, Apr 02, 2016 at 12:39:45PM -0400, Tom Herbert wrote:  
> > > Is there a hard restriction that this could only work with physical devices?  
> > I suppose not, but there wouldn't be much use case as compared to tc
> > ingress, no? Since I was imagining that this new hook would be more
> > restricted in functionality due to operating on descriptors rather than
> > with a full skb, I tried to think of an appropriate name.
> > 
> > If you think that this hook would spread, then a better name is needed.  
> 
> The thing that comes to mind is that this prog type makes it easier to
> implement batched processing of packets in BPF which would require major
> surgery across the tc layer to make it available in cls_bpf. Batched
> processing will be beneficial for software devices as well.

+1 agreed, I would really like to see batched processing of packets in
BPF, for this packet type, designed in from the start.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

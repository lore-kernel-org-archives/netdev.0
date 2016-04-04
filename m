From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC PATCH 1/5] bpf: add PHYS_DEV prog type for early driver
 filter
Date: Tue, 5 Apr 2016 00:07:14 +0200
Message-ID: <20160404220714.GB9972@pox.localdomain>
References: <1459560118-5582-1-git-send-email-bblanco@plumgrid.com>
 <1459560118-5582-2-git-send-email-bblanco@plumgrid.com>
 <CALx6S35N1W32e9fvAmEbPdZk1PK2eNUgd0uU7pteMkBoHUd36g@mail.gmail.com>
 <20160403070221.GF21980@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	ogerlitz@mellanox.com, Daniel Borkmann <daniel@iogearbox.net>,
	john fastabend <john.fastabend@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:35521 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbcDDWHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 18:07:18 -0400
Received: by mail-lb0-f172.google.com with SMTP id bc4so180349178lbc.2
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 15:07:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160403070221.GF21980@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/16 at 12:02am, Brenden Blanco wrote:
> On Sat, Apr 02, 2016 at 12:39:45PM -0400, Tom Herbert wrote:
> > Is there a hard restriction that this could only work with physical devices?
> I suppose not, but there wouldn't be much use case as compared to tc
> ingress, no? Since I was imagining that this new hook would be more
> restricted in functionality due to operating on descriptors rather than
> with a full skb, I tried to think of an appropriate name.
> 
> If you think that this hook would spread, then a better name is needed.

The thing that comes to mind is that this prog type makes it easier to
implement batched processing of packets in BPF which would require major
surgery across the tc layer to make it available in cls_bpf. Batched
processing will be beneficial for software devices as well.

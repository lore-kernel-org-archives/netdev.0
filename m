From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net resend] virtio_net: reject XDP programs using
 header adjustment
Date: Wed, 25 Jan 2017 22:49:11 -0500 (EST)
Message-ID: <20170125.224911.108489414049157715.davem@davemloft.net>
References: <5888C9B7.8040603@gmail.com>
        <20170125225636.167620-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com, mst@redhat.com,
        alexei.starovoitov@gmail.com, jasowang@redhat.com,
        john.r.fastabend@intel.com, daniel@iogearbox.net,
        oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdAZDtN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 22:49:13 -0500
In-Reply-To: <20170125225636.167620-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 25 Jan 2017 14:56:36 -0800

> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
> added a new XDP helper to prepend and remove data from a frame.
> Make virtio_net reject programs making use of this helper until
> proper support is added.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Applied.

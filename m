From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next RFC WIP] Patch for XDP support for virtio_net
Date: Fri, 28 Oct 2016 21:42:28 +0100
Message-ID: <20161028214228.7200fef2@jkicinski-Precision-T1700>
References: <20161028011739-mutt-send-email-mst@kernel.org>
        <20161027.213512.334468356710231957.davem@davemloft.net>
        <CAKgT0Ufe3QYtFpmtsL39-nbyy+YEt=gZKU_WUr9Wir+LTYLuEQ@mail.gmail.com>
        <20161027.221027.109834362557507518.davem@davemloft.net>
        <58137533.4030105@gmail.com>
        <20161028171812.48073f1f@jkicinski-Precision-T1700>
        <20161028182223.GA53930@ast-mbp.thefacebook.com>
        <CAKgT0UfZJ1wP9f-ZFVqdDUXMw90DKsRp+NDuam9YnHzbD=Tuig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        shrijeet@gmail.com, Tom Herbert <tom@herbertland.com>,
        Netdev <netdev@vger.kernel.org>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>,
        roopa <roopa@cumulusnetworks.com>, nikolay@cumulusnetworks.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:43863 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761149AbcJ1Umg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 16:42:36 -0400
In-Reply-To: <CAKgT0UfZJ1wP9f-ZFVqdDUXMw90DKsRp+NDuam9YnHzbD=Tuig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Oct 2016 13:35:02 -0700, Alexander Duyck wrote:
> > At the same time XDP doesn't require to use 4k buffer in something like Netronome.
> > If xdp bpf program can be offloaded into HW with 1800 byte buffers, great!  
> 
> So are you saying this is only really meant to be used with a full bpf
> hardware offload then?

I think Alexei just meant to say I don't have to worry about providing
4k buffers when program is offloaded but on the host a page is the
memory granularity for XDP...

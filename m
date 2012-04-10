From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v4 0/10] skb paged fragment destructors
Date: Tue, 10 Apr 2012 17:58:47 +0300
Message-ID: <20120410145845.GF19556@redhat.com>
References: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David VomLehn <dvomlehn@cisco.com>,
	Bart Van Assche <bvanassche@acm.org>,
	xen-devel <xen-devel@lists.xen.org>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758993Ab2DJO6m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 10:58:42 -0400
Content-Disposition: inline
In-Reply-To: <1334067965.5394.22.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 10, 2012 at 03:26:05PM +0100, Ian Campbell wrote:
>               * I can't for the life of me get anything to actually hit
>                 this code path. I've been trying with an NFS server
>                 running in a Xen HVM domain with emulated (e.g. tap)
>                 networking and a client in domain 0, using the NFS fix
>                 in this series which generates SKBs with destructors
>                 set, so far -- nothing. I suspect that lack of TSO/GSO
>                 etc on the TAP interface is causing the frags to be
>                 copied to normal pages during skb_segment().

To enable gso you need to call TUNSETOFFLOAD.

-- 
MST

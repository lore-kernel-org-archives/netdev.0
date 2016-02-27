From: Dominique Martinet <asmadeus@codewreck.org>
Subject: Re: [V9fs-developer] [PATCH] net/9p: convert to new CQ API
Date: Sat, 27 Feb 2016 16:49:57 +0100
Message-ID: <20160227154957.GA21186@nautica>
References: <1456565151-27115-1-git-send-email-hch@lst.de>
 <1456565151-27115-2-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nautica.notk.org ([91.121.71.147]:57614 "EHLO nautica.notk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756331AbcB0P7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2016 10:59:54 -0500
Content-Disposition: inline
In-Reply-To: <1456565151-27115-2-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Couple of checkpatch complains:

Christoph Hellwig wrote on Sat, Feb 27, 2016:
> -struct p9_rdma_context {
> -	enum ib_wc_opcode wc_op;
> +struct p9_rdma_context {	

trailing tab

> -	p9_debug(P9_DEBUG_ERROR, "req %p err %d status %d\n", req, err, status);
> +	p9_debug(P9_DEBUG_ERROR, "req %p err %d status %d\n", req, err, wc->status);

line over 80 chars


That aside it looks good ; I need to check on the new API (hadn't
noticed the change) but it looks nice.

Will do the actual testing likely only next week only though;
Eric has been taking my patches for 9p/RDMA so I suspect he'll take
your's as well eventually (get_maintainer.pl has a long-ish list of CC
for us usually)


BTW I think it's easy enough to do the testing if you have a server that
can dish it out. diod[1] and nfs-ganesha[2] are the only two I'm aware
of but there might be more (using ganesha myself; happy to help you set
it up in private if you need)

[1] https://github.com/chaos/diod
[2] https://github.com/nfs-ganesha/nfs-ganesha

-- 
Dominique Martinet

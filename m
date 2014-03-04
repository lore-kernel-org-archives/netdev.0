From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net 0/2] L2TP fixes
Date: Tue, 4 Mar 2014 22:38:57 +0100
Message-ID: <20140304213857.GA3029@alphalink.fr>
References: <cover.1393966618.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Chapman <jchapman@katalix.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:49443 "EHLO
	mail-2-cbv2.admin.alphalink.fr" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758520AbaCDVi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 16:38:59 -0500
Content-Disposition: inline
In-Reply-To: <cover.1393966618.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 04, 2014 at 10:24:54PM +0100, Guillaume Nault wrote:
> Here's a small series, to fix some (probably not widely used) L2TPv2
> features:
>   -toggling L2TP sequencing option from userspace was broken because
>    of missing header length update,
>   -no data was ever returned to userspace when reading from L2TP
>    sockets, because pppol2tp_recv() did only handle the case of
>    L2TP sockets bound to a PPP channel.
> 
This is based on 'net'. Sorry for having forgotten that in the subject.

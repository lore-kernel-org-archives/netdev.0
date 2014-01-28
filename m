From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC ipsec-next] xfrm: avoid creating temporary SA when there
 are no listeners
Date: Tue, 28 Jan 2014 08:59:10 +0100
Message-ID: <20140128075910.GP31491@secunet.com>
References: <1390729852-7842-1-git-send-email-horia.geanta@freescale.com>
 <1390729852-7842-2-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Horia Geanta <horia.geanta@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:58580 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751985AbaA1H7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jan 2014 02:59:14 -0500
Content-Disposition: inline
In-Reply-To: <1390729852-7842-2-git-send-email-horia.geanta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 26, 2014 at 11:50:52AM +0200, Horia Geanta wrote:
> In the case when KMs have no listeners, km_query() will fail and
> temporary SAs are garbage collected immediately after their allocation.
> This causes strain on memory allocation, leading even to OOM since
> temporary SA alloc/free cycle is performed for every packet
> and garbage collection does not keep up the pace.
> 
> The sane thing to do is to make sure we have audience before
> temporary SA allocation.
> 
> Signed-off-by: Horia Geanta <horia.geanta@freescale.com>

No objections from me, looks ok.

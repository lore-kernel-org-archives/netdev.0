From: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Tue, 21 Apr 2009 15:50:21 +0300
Message-ID: <20090421125020.GA9740@dhcp-1-124.tlv.redhat.com>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Rusty Russell <rusty@rustcorp.com.au>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:43608 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbZDUMvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 08:51:24 -0400
Received: by ewy24 with SMTP id 24so1570666ewy.37
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 05:51:22 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 20, 2009 at 02:25:27PM +0300, Michael S. Tsirkin wrote:
> The following patches make tun_chr_aio_read and tun_chr_aio_write not modify
> the iovec so that io_submit/io_getevents succeed, becoming functionally
> equivalent to write/read on the device.

What are the thoughts on these patches?
Is this a reasonable thing to do?

Thanks,
-- 
MST

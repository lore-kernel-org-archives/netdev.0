From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Xen-devel] [PATCHv1 net-next] xen-netback: remove
 unconditional pull_skb_tail in guest Tx path
Date: Tue, 04 Nov 2014 13:43:17 -0800
Message-ID: <1415137397.25370.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415036346.1411.3.camel@citrix.com>
	 <5457BF80.2000205@citrix.com> <5457C807.5080509@linaro.org>
	 <20141104.161704.1690311989900127361.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: zoltan.kiss@linaro.org, david.vrabel@citrix.com,
	Ian.Campbell@citrix.com, netdev@vger.kernel.org,
	malcolm.crossley@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:36663 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbaKDVnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 16:43:20 -0500
Received: by mail-ie0-f180.google.com with SMTP id y20so8223268ier.25
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 13:43:19 -0800 (PST)
In-Reply-To: <20141104.161704.1690311989900127361.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-04 at 16:17 -0500, David Miller wrote:


> 
> Every protocol demux starts with pskb_may_pull() to pull frag data
> into the linear area, if necessary, before looking at headers.

eth_get_headlen() might be relevant as well, to perform a single copy of
exactly all headers.

This is known to help a bit.

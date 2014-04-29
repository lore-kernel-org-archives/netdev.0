From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH 8/8 v3] net: Implmement RFC 6936 (zero csums for UDP/IPv6)
Date: Tue, 29 Apr 2014 19:16:09 +0200
Message-ID: <20140429171554.GA6456@omega>
References: <alpine.DEB.2.02.1404290902180.9964@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:45128 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757795AbaD2RQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 13:16:17 -0400
Received: by mail-ee0-f44.google.com with SMTP id c41so535074eek.17
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 10:16:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1404290902180.9964@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tom Herbert,

On Tue, Apr 29, 2014 at 09:19:18AM -0700, Tom Herbert wrote:
> RFC 6936 relaxes the requirement of RFC 2460 that UDP/IPv6 packets which
> are received with a zero UDP checksum value must be dropped. RFC 6936
> allows zero checksums to support tunnels over UDP.
> 
> When sk_no_check is set we allow on a socket we allow a zero IPv6
> UDP checksum. This is for both sending zero checksum and accepting
> a zero checksum on receive.
> 

I only want to mention that this is a interesting feature which we "maybe"
also can use for the 6LoWPAN IPHC format [0]. This is another possible use
case for this. We doesn't support this at the moment, maybe in the near
future...

It's to save some payload in the UDP header because we could drop the
checksum there, integrity check is already handeld by the MAC layer.

Cheers
Alex

[0] http://tools.ietf.org/html/rfc6282#section-4.3.2

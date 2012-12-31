From: Jamie Gloudon <jamie.gloudon@gmail.com>
Subject: Re: Is keepalive behaving as expected in 3.7.0+/net-next?
Date: Sun, 30 Dec 2012 21:50:09 -0400
Message-ID: <50e0ef55.11f2640a.4ef8.ffffd018@mx.google.com>
References: <50D4DD28.30903@hp.com>
 <1356645265.30414.1542.camel@edumazet-glaptop>
 <50df48f4.0e5b650a.36fa.1452@mx.google.com>
 <50E0A963.6080900@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <erdnetdev@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f44.google.com ([209.85.213.44]:62135 "EHLO
	mail-yh0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab2LaCRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 21:17:34 -0500
Received: by mail-yh0-f44.google.com with SMTP id 56so2041349yhq.17
        for <netdev@vger.kernel.org>; Sun, 30 Dec 2012 18:17:33 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <50E0A963.6080900@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 30, 2012 at 12:51:47PM -0800, Rick Jones wrote:
> >Make a lot of sense. However, I got the impression from Rick that
> >having tcp_keepalive_intvl > tcp_keepalive_time behaved correctly in
> >older versions of the kernel.
> 
> I seek to make no assertions about the behaviour of older kernels.  I was
> just going off the ip-sysctl.txt wording I was looking to clean-up.
> 
> rick

Ok, should ip-sysctl.txt documentation be updated to warn not to set tcp_keepalive_intvl > tcp_keepalive_time?

Regards,
Jamie Gloudon

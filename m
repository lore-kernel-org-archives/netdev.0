From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 23:06:08 +0100
Message-ID: <20080103220608.GB7258@ami.dom.local>
References: <20080103095829.GB2000@ff.dom.local> <200801031115.34886.paul.moore@hp.com> <20080103211312.GA7258@ami.dom.local> <200801031620.06603.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:27748 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036AbYACWC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 17:02:57 -0500
Received: by fg-out-1718.google.com with SMTP id e21so3452082fga.17
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 14:02:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200801031620.06603.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2008 at 04:20:06PM -0500, Paul Moore wrote:
...
> For me personally, I would argue the readability bit.  Whenever I see a 
> function/macro call I have to go find the function/macro definition 
> before I can understand what it is doing.  Granted, the macro is 
> defined "local" to the function but my point is that being able to look 
> at a line of code and understand it without having to look elsewhere is 
> a nice quality.  To loose that simply because someone wants to save a 
> few keystrokes is a mistake from my point of view.

When I first read this __skb_clone() I had mixed emotions about this
macro too. Later I didn't think about it, and only now, after your
question I've done a quick test, compared with __copy_skb_header() and
it seems there is really less rightwords eye moving. So, it was only
about this one very "local" macro.

I'm not macros fan in general: just yesterday I've cursed a bit at some
guy (I forgot the name...), who gave all these "meaningful" names to
macros in linux/pkt_cls.h. But, maybe after some time I'll start to
defend them as well... Especially when I try to imagine doing the same
without them.

Jarek P.

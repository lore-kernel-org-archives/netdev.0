From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: WARNING: at net/core/skbuff.c:154 with tcpdump and ipsec
Date: Fri, 13 Feb 2009 21:00:14 +0100
Message-ID: <20090213200014.GB2929@ami.dom.local>
References: <20090213121424.GA8717@ff.dom.local> <4995C241.1030507@hp.com> <20090213192448.GA2929@ami.dom.local> <4995CD0F.8020307@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Oledzki <ole@ans.pl>,
	Marco Berizzi <pupilla@hotmail.com>, netdev@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:49813 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550AbZBMT70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2009 14:59:26 -0500
Received: by fxm13 with SMTP id 13so3917207fxm.13
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2009 11:59:24 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4995CD0F.8020307@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 13, 2009 at 02:42:07PM -0500, Vlad Yasevich wrote:
...
> Personally, I think pskb_expand_head should fix the skb->truesize.  This
> way any subsequent clones will not trigger this warning.

Personally, I think there is no reason to call skb_truesize_bug() in
anything but some #ifdef CONFIG_XX_DEBUG, if we ignore these reports
for so long.

> Another alternative is to audit the pskb_expand_head() usages and adjust
> truesize in each case needed, which is just ugly.

I guess, it's a lot of work to do it right (if it's possible at all).
Yes, I think about something really ugly here. ;-)

Jarek P.

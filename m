From: "Hisham Kotry" <hkotry@gmail.com>
Subject: Re: skb diet
Date: Sun, 16 Apr 2006 14:56:53 +0200
Message-ID: <baebb9a00604160556o2abe6df1y4a185a0fd8f45e7b@mail.gmail.com>
References: <baebb9a00604150417h1ffb3f97g102253dca0b3a53e@mail.gmail.com>
	 <200604152122.01914.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pproxy.gmail.com ([64.233.166.178]:52946 "EHLO pproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1750726AbWDPM4y convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Apr 2006 08:56:54 -0400
Received: by pproxy.gmail.com with SMTP id i49so442454pye
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2006 05:56:53 -0700 (PDT)
To: "Andi Kleen" <ak@suse.de>
In-Reply-To: <200604152122.01914.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Where would that tag list be stored if you want to remove the
> 40 bytes of ->cb?

I apologize if I wasn't clear, the tag list would go in a new
skb->tags field replacing the existsing skb->cb array, so the skb
would lose 40-sizeof(void*) bytes wich seems reasonable to me.

> Linux 2.0 did something like this, but that was removed for good
> reasons. Now TCP always clones skbs before sending it out.

Do you remember what those reasons were? I couldn't find a related
discussion in the archives. I think the BSD mbuf tags approach is
sound enough to justify the move.

> And optimizing for uncommon cases (not TCP) doesn't seem too useful.

As pointed out by Bert Hubert, there are people who have heavy traffic
on non-tcp connections.

Thanks,
Hisham

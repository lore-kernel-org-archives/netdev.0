From: "Thibaut VARENE" <T-Bone@parisc-linux.org>
Subject: Re: [PATCH] Re: kernel BUG in eth_alloc_tx_desc_index at drivers/net/mv643xx_eth.c:1069!
Date: Tue, 23 Jan 2007 13:42:24 +0100
Message-ID: <7d01f9f00701230442t7d39ba72we6ec3fc6bc0556e9@mail.gmail.com>
References: <7d01f9f00701090227v60b37e5dy6afbf70ccde58bf2@mail.gmail.com>
	 <20070109200541.GA27089@xyzzy.farnsworth.org>
	 <7d01f9f00701091305n3a82713fla442a70a6098dbf@mail.gmail.com>
	 <7d01f9f00701100912kc6fb635wd863d9563b0eb328@mail.gmail.com>
	 <20070111104220.GA3171@ff.dom.local>
	 <7d01f9f00701210418q6f506d20tdc9ce10b501370d7@mail.gmail.com>
	 <7d01f9f00701210502m2bb96bd8i5071a76b6a8c3ea0@mail.gmail.com>
	 <20070122100236.GC2079@ff.dom.local>
	 <20070122170615.GA15293@xyzzy.farnsworth.org>
	 <7d01f9f00701230352r6e951b08wea2255ce0baeb40d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org,
	mlachwani@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.234]:21709 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964830AbXAWMm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 07:42:26 -0500
Received: by wr-out-0506.google.com with SMTP id 68so999628wra
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 04:42:25 -0800 (PST)
To: "Dale Farnsworth" <dale@farnsworth.org>
In-Reply-To: <7d01f9f00701230352r6e951b08wea2255ce0baeb40d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Thibaut VARENE <T-Bone@parisc-linux.org> wrote:
> - As Jarek pointed out, you're checking twice the value of
> mp->tx_desc_count, which means dereferencing a pointer and accessing
> memory twice. I don't know how perf-critical this bit of code is, but
> I wonder which of keeping the lock for a long time or doing what you
> is better (I'm being anal and you probably know that better than me :)

Forget that. That's an irq disabling lock, it's worse than anything else :)

-- 
Thibaut VARENE
http://www.parisc-linux.org/~varenet/

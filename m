From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.36-rc7: net/bridge causes temporary network I/O lockups [2]
Date: Tue, 19 Oct 2010 00:16:56 +0800
Message-ID: <20101018161656.GA2403@gondor.apana.org.au>
References: <4CB9EBC3.4070905@freenet.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Patrick Ringl <patrick_@freenet.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4CB9EBC3.4070905@freenet.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 16, 2010 at 08:15:31PM +0200, Patrick Ringl wrote:
> Hi,
>
> okay I narrowed down the issue. I watched all function calls of the  
> 'bridge' module with the help of a small systemtap probe of mine. I  
> first traced a timespan where the issue did not occur, then one where it  
> did and composed an intersection of these two:

I can't reproduce this problem here so I'll need your help to
track it down.

Can you see if you can relate the lock-ups to specific events
such as a particular packet being sent through the bridge?

If we can recreate the problem on demand that that helps us to
find the root cause.

You mentioned that you took packet dumps on the system.  If you
can show us the packets through the bridge and its ports when
the problem occurs that would be great.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

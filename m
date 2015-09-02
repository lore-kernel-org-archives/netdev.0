From: Ken-ichirou MATSUZAWA <chamaken@gmail.com>
Subject: Re: [PATCHv1 net-next 0/5] netlink: mmap: kernel panic and some
 issues
Date: Thu, 3 Sep 2015 07:27:10 +0900
Message-ID: <20150902222710.GA7746@gmail.com>
References: <20150814085807.GA30443@gmail.com>
 <55CDBC84.8020605@iogearbox.net>
 <55CDC51D.1060204@iogearbox.net>
 <20150817.140222.1763422851882964859.davem@davemloft.net>
 <55D492CC.6010602@iogearbox.net>
 <20150902000400.GA14821@gmail.com>
 <55E6C5AE.4060308@iogearbox.net>
 <20150902113553.GA3282@gmail.com>
 <55E71C34.1080504@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fw@strlen.de
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36297 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbbIBW1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 18:27:16 -0400
Received: by pacwi10 with SMTP id wi10so24504971pac.3
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 15:27:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55E71C34.1080504@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2015 at 05:56:36PM +0200, Daniel Borkmann wrote:
> you suggest or not), for two reasons: I think (will start experimenting
> more with it tomorrow), you would get an out of bounds access here in
> case the skb->data is the last slot in the ring buffer and reaches
> exactly to the ring buffer end. And (despite that), it's also hard

I thought accessing as a value, not a pointer, in thats wrong shared
info will not be a big problem, but

> to maintain - the next one adding a new shared info member will very
> likely oversee this special case in netlink here, thus the issue would
> then simply be reintroduced over and over.

I agree with you.
Thank you for taking your time. I think I have learned a lot.

Thanks,

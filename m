From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/4] net: increase frag hash size
Date: Thu, 25 Apr 2013 12:13:15 +0200
Message-ID: <1366884795.26911.510.camel@localhost>
References: <20130424154624.16883.40974.stgit@dragon>
	 <20130424154822.16883.93014.stgit@dragon>
	 <51785827.1000007@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757309Ab3DYKNZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Apr 2013 06:13:25 -0400
In-Reply-To: <51785827.1000007@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-04-25 at 02:09 +0400, Sergei Shtylyov wrote:
> On 24-04-2013 19:48, Jesper Dangaard Brouer wrote:
> 
> > Increase fragmentation hash bucket size to 1024 from old 64 elems.
> 
> > After we increased the frag mem limits (in commit v3.8-rc3-503-gc2a9366)
> 
>     This is not a commit ID, commit ID is SHA1 key alone. And you should also 
> specify that commit's summary line with it, in parens.

Did you know that you can use the string "v3.8-rc3-503-gc2a9366" like:
 git show v3.8-rc3-503-gc2a9366
That's why I like this kind of commit ID better, as it also tell the
reader what approx version this patch were in.

But you are right about the title in parentheses...

Dave, do you want me to resubmit this, with nitpicked commit message?

--JEsper

From: Willy Tarreau <w@1wt.eu>
Subject: Re: splice() giving unexpected EOF in 3.7.3 and 3.8-rc4+
Date: Sat, 19 Jan 2013 08:04:27 +0100
Message-ID: <20130119070427.GC6838@1wt.eu>
References: <20130119044957.GA25395@dcvr.yhbt.net> <1358574847.3464.422.camel@edumazet-glaptop> <1358575996.3464.447.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Wong <normalperson@yhbt.net>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1358575996.3464.447.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 18, 2013 at 10:13:16PM -0800, Eric Dumazet wrote:
> On Fri, 2013-01-18 at 21:54 -0800, Eric Dumazet wrote:
> 
> > 
> > Hmm, this might be already fixed in net-next tree, could you try it ?
> > 
> 
> Yes, running your program on net-next seems OK.
> 
> David, we need the two following commits.
> 
> They actually fixed a bug : current code in Linus tree
> can push to the pipe a 0-length frag, because of the :
(...)

And FWIW I confirm that my test machines which have been running 3.7
with these two patches since you proposed them have never experienced
such an issue.

Willy

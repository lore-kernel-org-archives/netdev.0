From: Michael Shuldman <michaels@inet.no>
Subject: Re: bug in select(2) regarding non-blocking connect(2) completion?
Date: Sat, 7 May 2011 18:06:28 +0200
Message-ID: <20110507160628.GA11163@jensen.inet.no>
References: <20110507105152.GA13459@jensen.inet.no>
 <1304770358.2821.1139.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, karls@inet.no,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304770358.2821.1139.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote,
> Well, if you missed the original error report, all next getpeername()
> and SO_ERROR will do the same, and select() says fd is ready for 'write'

Many thanks for that.  I was not aware that SO_ERROR would not get
set if the connect(2) failed "permanently" immediately, but have
now tested that it does.  The other "strangeness" might very well
be caused by bugs related to this, so apologies for the noise and
many thanks for the help.

With kind regards,

-- 
  _ // 
  \X/ -- Michael Shuldman 

From: Ben Greear <greearb@candelatech.com>
Subject: Re: inter-packet gap in pktgen
Date: Tue, 07 Dec 2004 14:47:15 -0800
Message-ID: <41B632F3.1090104@candelatech.com>
References: <20041207222522.GA30266@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041207222522.GA30266@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:

> By tweaking the 'ipg' parameter I can generate pretty much any packet rate
> I want, as long as I set ipg=(1e9/rate)-496 instead of something possibly
> more straightforward.

That 496 will also change with load on the system, at least on average.  I
dealt with this by having a user-space app sample the rate and adjust the ipg
to keep the average rate where I want it.

So, I'd suggest leaving the ipg as it is, and use external tools to get
the exact pps that you are looking for.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

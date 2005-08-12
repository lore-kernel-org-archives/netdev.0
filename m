From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 0/8] netpoll: various bugfixes
Date: Fri, 12 Aug 2005 12:21:52 -0700
Message-ID: <20050812192152.GJ12284@waste.org>
References: <1.502409567@selenic.com> <20050812172151.GA11104@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>,
        ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Olaf Hering <olh@suse.de>
Content-Disposition: inline
In-Reply-To: <20050812172151.GA11104@suse.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[corrected akpm's address]

On Fri, Aug 12, 2005 at 07:21:51PM +0200, Olaf Hering wrote:
>  On Thu, Aug 11, Matt Mackall wrote:
> 
> > This patch series cleans up a few outstanding bugs in netpoll:
> > 
> > - two bugfixes from Jeff Moyer's netpoll bonding
> > - a tweak to e1000's netpoll stub
> > - timeout handling for e1000 with carrier loss
> > - prefilling SKBs at init
> > - a fix-up for a race discovered in initialization
> > - an unused variable warning
> 
> Matt, I have tested them, the sender doesnt lockup anymore. But a
> task dump doesnt work, I get only the first task. This is on a 3GHz xeon
> with tg3 card.

Does the task dump work without patch 5/8 (add retry timeout)? I'll
try testing it here.

-- 
Mathematics is the supreme nostalgia of our time.

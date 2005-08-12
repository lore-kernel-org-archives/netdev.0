From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH 0/8] netpoll: various bugfixes
Date: Fri, 12 Aug 2005 19:21:51 +0200
Message-ID: <20050812172151.GA11104__9254.86446726627$1123867565$gmane$org@suse.de>
References: <1.502409567@selenic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@osdl.com>, "David S. Miller" <davem@davemloft.net>,
        ak@suse.de, Jeff Moyer <jmoyer@redhat.com>, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org, mingo@elte.hu, john.ronciak@intel.com,
        rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <1.502409567@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 On Thu, Aug 11, Matt Mackall wrote:

> This patch series cleans up a few outstanding bugs in netpoll:
> 
> - two bugfixes from Jeff Moyer's netpoll bonding
> - a tweak to e1000's netpoll stub
> - timeout handling for e1000 with carrier loss
> - prefilling SKBs at init
> - a fix-up for a race discovered in initialization
> - an unused variable warning

Matt, I have tested them, the sender doesnt lockup anymore. But a
task dump doesnt work, I get only the first task. This is on a 3GHz xeon
with tg3 card.

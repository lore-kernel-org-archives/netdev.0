From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] pktgen: reduce stack usage
Date: Fri, 18 Feb 2005 18:56:36 -0800
Message-ID: <4216AAE4.1080804@candelatech.com>
References: <20050218134219.3f079110.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev <netdev@oss.sgi.com>
To: "Randy.Dunlap" <rddunlap@osdl.org>
In-Reply-To: <20050218134219.3f079110.rddunlap@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Randy.Dunlap wrote:
> (resend)
> Any comments this time?
> 
> 
> 
> pktgen: proc_if_write: reduce stack usage (on i386)
> from 776 to 296 bytes by combining/reusing locals.

Since these methods are not in the fast path, and the stack
usage is not near 4k, does this really matter?

I'm asking more to be educated than to dismiss the changes....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

From: Ben Greear <greearb@candelatech.com>
Subject: Re: netdev_ops?
Date: Tue, 22 Jul 2003 23:36:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E2CE9.2080404@candelatech.com>
References: <3F1E17BC.30100@candelatech.com>	<20030722220745.379a73c6.davem@redhat.com>	<3F1E1D62.90009@candelatech.com>	<20030722230215.284dd270.davem@redhat.com>	<3F1E2A00.5080506@candelatech.com> <20030722232719.216d7823.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030722232719.216d7823.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> You gain nothing from this patch, just put it into your drivers.

I am not writing drivers, I'm trying to write code that works with
everything that looks remotely like an ethernet device.  Thus,
I can make this one change and work with ALL drivers, and not have
to corrupt every friggin driver under the sun.

And yes, I realize this patch is not adding a new ioctl..that is the
whole point.

> 
> Your patch is even more useless than I thought it was going to
> be. :-)

I really hope you mis-understood it :)

Note it allows me to get a binary representation of the net_device_stats
w/out having to parse /proc/net/dev or figure out the vast complexity
of libnetlink.

I have plenty of other things that are currently new ioctls that could
be handled the same, and thus I could continue to avoid issues with
other platforms.

Ben


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

From: Dan Aloni <da-x@gmx.net>
Subject: Re: [PATCH] network device renaming sysfs fix
Date: Sun, 17 Aug 2003 10:13:07 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817071307.GA11408@callisto.yi.org>
References: <20030815111514.GA5228@callisto.yi.org> <20030815093724.519779e6.shemminger@osdl.org> <20030816074014.46b228f5.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
   mhuth@mvista.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030816074014.46b228f5.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 16, 2003 at 07:40:14AM -0700, David S. Miller wrote:
> On Fri, 15 Aug 2003 09:37:24 -0700
> Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > The class_dev kobject name is 20 chars and IFNAMSIZ is 16, so the solution
> > needs to truncate if new_name is not null terminated (all 16 chars long).
> > 
> > This seems like the best approach:
> 
> Patch applied, thanks everyone.
> 
> Can't the device name also change via netlink messages?
> If so, do we handle that case properly?

No it can't, AFAIK. You might be confusing between netlink and 
notifier calls (which allow ipv4 to update the names of aliases
when the device name changes).

BTW, it is possible to add notifier handling for fixing device 
naming discrepancies regarding family-level sysctl registration. 
I think this is how the sysctl issue should be fixed.

-- 
Dan Aloni
da-x@gmx.net

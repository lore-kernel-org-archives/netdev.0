From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] network device renaming sysfs fix
Date: Sat, 16 Aug 2003 07:40:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816074014.46b228f5.davem@redhat.com>
References: <20030815111514.GA5228@callisto.yi.org>
	<20030815093724.519779e6.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: da-x@gmx.net, netdev@oss.sgi.com, mhuth@mvista.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030815093724.519779e6.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2003 09:37:24 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The class_dev kobject name is 20 chars and IFNAMSIZ is 16, so the solution
> needs to truncate if new_name is not null terminated (all 16 chars long).
> 
> This seems like the best approach:

Patch applied, thanks everyone.

Can't the device name also change via netlink messages?
If so, do we handle that case properly?

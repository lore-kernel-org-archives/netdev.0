From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] proc_net macro's for non-proc-fs case
Date: Fri, 12 Sep 2003 17:13:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912171341.60157cbc.davem@redhat.com>
References: <20030911154357.6b31891c.shemminger@osdl.org>
	<20030911235405.GA74116@compsoc.man.ac.uk>
	<20030912112120.23300a99.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: levon@movementarian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030912112120.23300a99.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 12 Sep 2003 11:21:20 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The following should work better. They have the desired properties that:
> 	- return value makes sense for those that might check
> 	- arguments fops and info don't have to be defined (ie can be #ifdef'd out)
> 	- generate no warnings for null effect.

Looks good, applied thanks.

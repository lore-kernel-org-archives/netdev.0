From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6] netem update
Date: Fri, 27 Aug 2004 16:56:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040827165659.616ed762.davem@redhat.com>
References: <20040827121752.6b7fdf82@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@znyx.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040827121752.6b7fdf82@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 27 Aug 2004 12:17:52 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This is a third revision of the netem extensions which provides
> 	* packet duplication
> 	* correlated random number
> 	* loading distribution table
> 
> The API is backwards compatible and now uses nested elements to allow
> for easier future changes.

Looks great, applied.  A 2.4.x version is coming? :-)

Also, if someone is bored, can we get the pkt_sched.h
enumeration stuff cleaned up a bit?  I mean, instead
of all of these error prone FOO_MAX tricks, just do
what we do for the netlink headers.

enum {
	FOO_A,
	FOO_B,
	...
	__FOO_MAX,
};

#define FOO_MAX		(__FOO_MAX - 1)

This way to add new enumerations is just a one line
change and less error prone.

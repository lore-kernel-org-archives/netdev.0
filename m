From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] support for large number of network devices.
Date: Wed, 14 Jan 2004 11:37:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040114113734.4e9a0865.shemminger@osdl.org>
References: <20040113154610.38f5934c.shemminger@osdl.org>
	<20040113155921.342db463.davem@redhat.com>
	<20040113161303.20f1159d.shemminger@osdl.org>
	<20040114071303.GG28521@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20040114071303.GG28521@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Unfortunately sscanf("eth0-not-allocated", "eth%d", &i) fools it.
> Which may or may not be worth worrying about.

Hmmm,  the old code would have assigned "eth0" in that case, new code
would assign "eth1".  Other difference is in the case of whitespace.
scanf("white  space0", "white space%d", &i)
because any whitespace matches multiple whitespace characters.

Is it worth making a separate explicit match routine?

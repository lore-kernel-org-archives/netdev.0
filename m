From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (4/9) bridge - use ethtool to get port speed
Date: Fri, 16 Apr 2004 14:15:37 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416141537.74dd31ec.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413152440.7e410cd8@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413152440.7e410cd8@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:24:40 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The bridge code needs to keep track of a cost estimate for each
> port in the bridge.  Instead of a hack based on device name, try
> and use ethtool to get port speed from device.  This has been tested
> on e100 (uses ethtool_ops) and e1000 (does ethtool the hard way)
> and dummy (no ethtool).

Looks fine, applied.

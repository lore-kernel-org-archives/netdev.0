From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.6.5] (2/9) bridge - rmmod race
Date: Fri, 16 Apr 2004 14:13:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040416141349.6465c878.davem@redhat.com>
References: <20040413151630.710042e3@dell_ss3.pdx.osdl.net>
	<20040413151847.50c62126@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040413151847.50c62126@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2004 15:18:47 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fix observed race between removing bridge module and ip packets
> in flight.  Need to remove the hook last, after all bridges are gone
> not the other way around.

Applied.

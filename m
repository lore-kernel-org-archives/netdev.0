From: "David S. Miller" <davem@redhat.com>
Subject: Re: [RFC] netem - add jitter support.
Date: Fri, 9 Jul 2004 16:53:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040709165314.485cdc52.davem@redhat.com>
References: <20040708135320.03366bd7@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040708135320.03366bd7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Jul 2004 13:53:20 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch adds jitter if desired to the delayed packets in the
> netem scheduler.  I dropped the rate stuff out and reorganized so
> that an underlying pfifo queue is used (next plan is to make it
> have class ops).
> 
> The jitter is given as sigma to a Gaussian normal distribution.  The actual
> implementation is a reduced form of the table driven stuff in NISTnet
> (free). 

I'm going to apply this.  Stephen please send me
a 2.4.x version as well.

Thanks.

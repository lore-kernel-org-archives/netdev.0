From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] netem - add jitter support.
Date: 08 Jul 2004 21:14:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1089335650.1046.150.camel@jzny.localdomain>
References: <20040708135320.03366bd7@dell_ss3.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040708135320.03366bd7@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-07-08 at 16:53, Stephen Hemminger wrote:
> This patch adds jitter if desired to the delayed packets in the
> netem scheduler.  I dropped the rate stuff out and reorganized so
> that an underlying pfifo queue is used (next plan is to make it
> have class ops).
> 
> The jitter is given as sigma to a Gaussian normal distribution.  The actual
> implementation is a reduced form of the table driven stuff in NISTnet
> (free). 

Good stuff. 
- Is that NIST code/reference ok to put there? I have a feeling its
non-free.
- Could that table be computed in user space instead? This way you are
not restricted to just the normal distribution. I could also use them
if available from within tc sources,

cheers,
jamal

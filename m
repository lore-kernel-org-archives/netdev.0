From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] gc_min_interval in milleseconds via /proc (fwd)
Date: Sun, 30 Jan 2005 22:56:27 -0800
Message-ID: <20050130225627.4feecd2e.davem@davemloft.net>
References: <16888.56016.608929.340640@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16888.56016.608929.340640@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 13:13:04 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

>   Ok! But I haven't heard of any successful use of this paticaul API. :-)

Are you really so sure?

>  > We could instead make another sysctl (perhaps name it something
>  > like "gc_min_interval_ms") to do what you propose, and then
>  > we'd keep the existing one around for compatibility.
> 
>  All-right a new patch below. 

We must pick a new sysctl number too, for sysctl() system call.
If the only access possible were through /proc then yes your
change would be valid, but due to sysctl() system call the
.ctl_name defines that dimension of the sysctl namespace.

From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: b44 driver in Linux 2.4.22
Date: Tue, 26 Aug 2003 10:00:55 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826070055.GA19639@ee.oulu.fi>
References: <Pine.LNX.4.55.0308260936140.17569@dodo>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Antliff <dave.antliff@paradise.net.nz>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.55.0308260936140.17569@dodo>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Aug 26, 2003 at 09:38:45AM +1200, David Antliff wrote:
> 
> Hi,
> 
> Does the b44 driver you wrote in Linux 2.4.22 support magic
> packet Wake-On-Lan?
Hi

Not in the current version. Doesn't look that difficult to add though, 
so I might at some point have a go at implementing it. Just need to figure
out how to test it, I assume there's ACPI hell involved :/
 
> Also, just out of curiosity, is this driver based on Michael Chan's
> Broadcom bcm4400 driver?
Dave would know best since he wrote the beast, but I believe it's 
written using bcm4400 as "documentation" and really based on the
generic Linux ethernet driver template (so tg3.c with tg3 bits changed 
into b44 bits :-) )

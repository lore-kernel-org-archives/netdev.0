From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 3c59x (was Route cache performance under stress)
Date: Tue, 10 Jun 2003 12:23:42 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610162342.GB1959@gtf.org>
References: <20030610.085342.41654796.davem@redhat.com> <Pine.LNX.4.44.0306101801070.26879-100000@kenzo.iwr.uni-heidelberg.de> <20030610162029.GA8168@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>,
   "David S. Miller" <davem@redhat.com>, hadi@shell.cyberus.ca,
   ralph+d@istop.com, xerox@foonet.net, sim@netnation.com, fw@deneb.enyo.de,
   netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
Content-Disposition: inline
In-Reply-To: <20030610162029.GA8168@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 10, 2003 at 06:20:29PM +0200, Andi Kleen wrote:
> Can't you just wrap it in a few macros and offer a config for those
> who want the best performance and a runtime test for the others?
> Then switch between PIO and mmio dynamically.
> 
> Even runtime test should be pretty painless these days, the CPU normally
> can execute hundreds or even thousands of tests in the time it takes to 
> wait for an mmio or even PIO.

I prefer a compile-time test.  But yes, this is what several other
net drivers do:  offer a config option for MMIO (or PIO), and the
default is MMIO unless that is known to be unsafe on certain boards
(which, unfortunately, it is).

	Jeff

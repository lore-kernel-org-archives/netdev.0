From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] hp100 -- fixes for new probing.
Date: Wed, 25 Feb 2004 13:40:36 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040225134036.4132c060@dell_ss3.pdx.osdl.net>
References: <20040224170700.11adc3cc@dell_ss3.pdx.osdl.net>
	<20040225213347.5491.qmail@web14006.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Cacophonix <cacophonix@yahoo.com>
In-Reply-To: <20040225213347.5491.qmail@web14006.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 25 Feb 2004 13:33:47 -0800 (PST)
Cacophonix <cacophonix@yahoo.com> wrote:

> 
> Yes, this fixes the lockup issue (once I renamed addr to ioaddr in hp100_isa_probe1()
> to get it to compile. Thanks for the patch!
> 
> Next order of business for me is to figure out why the ordering of device recognition
> of e100 and hp100 changed between 2.6.0-test* and 2.6.3-mm2 (in the former, hp100 
> started up first, while in the latter kernel e100 get's to load up first). I guess I 
> could work around this in other ways, but it's a tad disconcerting when eth0, eth1 
> and eth2 decide to trade places every so often ;)
> 

The naming is a function of initialization order which used to be fixed by a long list
of legacy devices.  Since the hp100 pci now probes like a proper PCI device, it will
happen in a order defined by the load order (ie not well controlled). 

Learn to use nameif it will make your life simpler.

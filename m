From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: network interface cards native vlans support in linux kernel?
Date: Fri, 11 Jul 2003 13:18:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711171858.GI2210@gtf.org>
References: <Pine.LNX.4.44.0307111754220.6646-100000@hl.kauneta.net> <3F0EEFDD.8050300@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrius Kasparavicius <andrius@andrius.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3F0EEFDD.8050300@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 10:11:57AM -0700, Ben Greear wrote:
> eepro100 does not seem to be updated in the kernel anymore, though if you 
> go figure
> out how to install Becker's drivers, he may have it working with vlans
> by now.

I won't say for sure, but I'm fairly certain he does.  Most of his
drivers got a "slightly larger than normal MTU" pass-over a while ago.

I objected to the eepro100 patch, because all it did was change one
magic number to another, in the configuration data.  I had absolutely no
basis for evaluation other than "I hope it works", so it was rejected.

If someone wants to look at his eepro100 and merge in new changes (vlan
or otherwise), that'd be great.  His tulip MTU (aka vlan) changes also
want pulling into mainline kernel, since his changes are _much_ better
than the tulip vlan patch floating around.

	Jeff

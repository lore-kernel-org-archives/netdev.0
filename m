From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Device naming for wireless NICs...
Date: Thu, 11 Mar 2004 13:23:12 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4050AE90.9070005@pobox.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <20040311024816.GC3738@jm.kir.nu> <404FD6BC.7090409@pobox.com> <20040311031709.GC3782@jm.kir.nu> <405093A7.90209@linux.co.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Ketrenos <jketreno@linux.co.intel.com>
In-Reply-To: <405093A7.90209@linux.co.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Ketrenos wrote:
> 
> If this topic been hashed a lot already, please let me know the keywords 
> I might search for in the archives to find the threads.
> 
> I've had a few requests by users of the IPW2100 wireless driver to 
> switch the default interface name to be wlanX vs. ethX.  In my prior 
> searches through the wireless drivers in the 2.6.3 kernel tree, I 
> couldn't find any that changed from the default.

I lean towards wlan%d, but until we have the generic 802.11 stack going 
it's really up to the driver maintainer (you, in this case).

Like Matthew said, any code that assumes a specific interface prefix, be 
it eth%d or wlan%d, is buggy.  Users are allowed to choose random 
interface names for their interfaces, often via nameif(8) program.  My 
own ethtool program is broken in this regard...

	Jeff

From: James Ketrenos <jketreno@linux.co.intel.com>
Subject: Device naming for wireless NICs...
Date: Thu, 11 Mar 2004 10:28:23 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <405093A7.90209@linux.co.intel.com>
References: <20040304023524.GA19453@bougret.hpl.hp.com> <20040310165548.A24693@infradead.org> <20040310172114.GA8867@bougret.hpl.hp.com> <404F5097.4040406@pobox.com> <20040310175200.GA9531@bougret.hpl.hp.com> <404F5744.1040201@pobox.com> <20040311024816.GC3738@jm.kir.nu> <404FD6BC.7090409@pobox.com> <20040311031709.GC3782@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20040311031709.GC3782@jm.kir.nu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


If this topic been hashed a lot already, please let me know the keywords I might 
search for in the archives to find the threads.

I've had a few requests by users of the IPW2100 wireless driver to switch the 
default interface name to be wlanX vs. ethX.  In my prior searches through the 
wireless drivers in the 2.6.3 kernel tree, I couldn't find any that changed from 
the default.

I don't mind adding a module parameter to change the default name (if that is 
the standard practice), but thought I'd see what others thing rather than just 
going off and doing something random.

Is there a technical or ease of use reason switching away from ethX?  My 
thinking in keeping it eth was that it then represents a greater chance of "just 
working" with most networking scripts and utilities that may assume ethX is the 
interface name.

Thanks,
James

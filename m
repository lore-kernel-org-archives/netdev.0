From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: forcedeth: version 0.17 available
Date: Mon, 17 Nov 2003 09:08:42 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311171708.hAHH8he01546@dyn318364bld.beaverton.ibm.com>
References: <3FB807A3.8010207@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: c-d.hailfinger.kernel.2003@gmx.net (Carl-Daniel Hailfinger)
In-Reply-To: <3FB807A3.8010207@gmx.net> from "Carl-Daniel Hailfinger" at Nov 17, 2003 12:26:27 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Carl-Daniel,

I just went through a similar oops for another driver last Thursday.  Move the
register_netdev(dev) after the initialization of 'dev->dev_stats = get_stats;'
and the oops should be eliminated.

Don
> 
> Hello all,
> 
> version 0.17 of forcedeth for Linux 2.4 and 2.6 is available at
> http://www.hailfinger.org/carldani/linux/patches/forcedeth/
> 
> Fixes in this release over 0.14:
> *  0.15: 08 Nov 2003: fix smp deadlock with set_multicast_list
> *                     during open.
> *  0.16: 15 Nov 2003: include file cleanup for ppc64, rx buffer
> *                     size increased to 1628 bytes.
> *  0.17: 16 Nov 2003: undo rx buffer size increase. Substract 1
> *                     from the tx length.
> 
> Known issues:
> *  Oops during module removal, probably sysfs related. Could a
>    sysfs expert please take a look at the code? Call trace is at
>    http://www.ussg.iu.edu/hypermail/linux/kernel/0311.1/0213.html
>    More traces (roughly the same) available on request.
> *  Some boards give bogus MAC addresses and work only partially.
>    Same problem happens with nvnet on these boards.
> *  Transmit for packets close to MTU size was broken, should be
>    fixed now.
> 
> Please test.
> 
> 
> Regards,
> Carl-Daniel
> 
> 
> 
>


-- 
Don Fry
brazilnut@us.ibm.com

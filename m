From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 19:14:24 -0400
Message-ID: <4C3F9650.1040800@tmr.com>
References: <4C3D94E3.9080103@wildgooses.com>	<4C3DD5EB.9070908@tmr.com> <20100714.111553.104052157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100714.111553.104052157.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Bill Davidsen <davidsen@tmr.com>
> Date: Wed, 14 Jul 2010 11:21:15 -0400
> 
>> You may have to go into /proc/sys/net/core and crank up the
>> rmem_* settings, depending on your distribution.
> 
> You should never, ever, have to touch the various networking sysctl
> values to get good performance in any normal setup.  If you do, it's a
> bug, report it so we can fix it.
> 
> I cringe every time someone says to do this, so please do me a favor
> and don't spread this further. :-)
> 
I think transit time measured in 1/10th sec would disqualify this as a "normal 
setup."

High bandwidth and high latency don't work well because you get "send until the 
window is full then wait for ack" and poor performance. I saw this with sat feed 
to Wyoming from GE's Research Center in upstate NY in the late 80's or early 
90's. (I think this was NYserNet at that time). I did feeds from NYC area to 
California and Hawaii with SBC in the early to mid 2k years. In every case 
SunOS, Solaris, AIX and Linux all failed to hit anything like reasonable 
transfer speeds without manually tweaking, and I got the advice on increasing 
window size from network engineers at ISPs and backbone providers.

The O.P. may have other issues, and may benefit from doing other things as well, 
but raising window size is a reasonable thing to do on links with RTT in 
hundreds of ms, and it's easy to try without changing config files.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot

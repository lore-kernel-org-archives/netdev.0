From: george anzinger <george@mvista.com>
Subject: Re: Network oops
Date: Sun, 09 Jun 2002 21:48:15 -0700
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae1bb3$3gf$2@main.gmane.org>
References: <200205202125.BAA03545@sex.inr.ac.ru>
		<3D0390E2.1B80ADEE@mvista.com> <20020609.213150.32126725.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

"David S. Miller" wrote:
> 
> No mention of what kernel version, what patches applied, etc.
> so we cannot help you.

Sorry bout that.  It is a 2.4.17 kernel and the test is to
verify that we have the preempt code right.  The question at
hand is if this is a likely preempt problem or just a pure
overload.  The stress on the network is rather high.

I would expect that the network code would recover from this
sort of thing, so we are looking for a preempt issue at the
moment.  Still, it could just be the way things work in the
2.4.17 kernel so I thought I would ask.

-- 
George Anzinger   george@mvista.com
High-res-timers: 
http://sourceforge.net/projects/high-res-timers/
Real time sched:  http://sourceforge.net/projects/rtsched/
Preemption patch:
http://www.kernel.org/pub/linux/kernel/people/rml

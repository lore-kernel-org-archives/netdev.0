From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
 RLT-8139 related)
Date: Tue, 27 Jul 2004 22:24:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16646.47585.814327.628319@robur.slu.se>
References: <16646.14381.740376.204381@robur.slu.se>
	<Pine.LNX.4.44.0407271710070.3787-100000@silmu.st.jyu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Francois Romieu <romieu@fr.zoreil.com>,
        H?ctor Mart?n <hector@marcansoft.com>,
        Linux-Kernel <linux-kernel@vger.kernel.org>, <akpm@osdl.org>,
        <netdev@oss.sgi.com>, <brad@brad-x.com>, <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pasi Sjoholm <ptsjohol@cc.jyu.fi>
In-Reply-To: <Pine.LNX.4.44.0407271710070.3787-100000@silmu.st.jyu.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Pasi Sjoholm writes:

 > Yeah, when the ksoftirqd is taking all the cpu it will be like that, but 
 > when the kernel is behaving normally the starving diff is between 0->1sec.

 Well ksoftirqd makes your kernel load just visible which is good and 
 ksofirqd gets accounted for this when softirq's get deferred to it.
 It may look like goes from 0 to 100% but thats probably not the case.
 The problem is we can starve userland at high loads. As said we were
 trying some way to cure this I may have some old patch if you like to try.

 Cheers.
						--ro
 

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 auto speed down issue
Date: Sat, 30 Mar 2013 13:42:56 +0100
Message-ID: <20130330124256.GA19236@electric-eye.fr.zoreil.com>
References: <4EECA12DD88643FD9006350514D96C8E@realtek.com.tw>
 <20130328231955.GA26182@electric-eye.fr.zoreil.com>
 <83FC3118294143DC81063B29EF570FC1@realtek.com.tw>
 <20130329072056.GA31269@electric-eye.fr.zoreil.com>
 <555174DCA0B0431BB3AE9CCD464E5896@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bowgotsai@google.com, "'Ryankao'" <ryankao@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <555174DCA0B0431BB3AE9CCD464E5896@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
[...]
> Sorry for my unclear descriptor. I just think a case that the nic suspends or
> shutdowns without cable plugging. Then, the cable is plugged again. If the nic
> speed down to 10M and the link partner force 100M, the issue appears again. If
> the nic doesn't speed down for normal link partner, it requires more power
> when the linking recovers.

Yes. The nic can not guess what the user values most: power saving in a
stable link layer configuration vs ability to detect and adapt to a yet
unseen configuration.

It could be a reason why EEE exists.

> Finally, I determine to set the speed to 10M when the link partner supports
> 10M. And for the other case, setting the speed to 100M. This avoids the giga
> nic to keep the speed to 1000M, and could fix this issue.
> However, I wonder if there is a switch which forces the speed to giga.

We can check if the partner supports 100M too. It's almost free and it will
avoid this problem.

-- 
Ueimor

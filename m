From: hayeswang <hayeswang@realtek.com>
Subject: RE: r8169 auto speed down issue
Date: Fri, 29 Mar 2013 16:20:43 +0800
Message-ID: <555174DCA0B0431BB3AE9CCD464E5896@realtek.com.tw>
References: <4EECA12DD88643FD9006350514D96C8E@realtek.com.tw> <20130328231955.GA26182@electric-eye.fr.zoreil.com> <83FC3118294143DC81063B29EF570FC1@realtek.com.tw> <20130329072056.GA31269@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<bowgotsai@google.com>, 'Ryankao' <ryankao@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130329072056.GA31269@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Friday, March 29, 2013 3:21 PM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> bowgotsai@google.com; Ryankao
> Subject: Re: r8169 auto speed down issue
> 
[...]
> 
> I don't get your point. Can you reformulate ?

Sorry for my unclear descriptor. I just think a case that the nic suspends or
shutdowns without cable plugging. Then, the cable is plugged again. If the nic
speed down to 10M and the link partner force 100M, the issue appears again. If
the nic doesn't speed down for normal link partner, it requires more power when
the linking recovers. Finally, I determine to set the speed to 10M when the link
partner supports 10M. And for the other case, setting the speed to 100M. This
avoids the giga nic to keep the speed to 1000M, and could fix this issue.
However, I wonder if there is a switch which forces the speed to giga.

Best Regards,
Hayes

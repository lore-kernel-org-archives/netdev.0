From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 auto speed down issue
Date: Fri, 29 Mar 2013 08:20:56 +0100
Message-ID: <20130329072056.GA31269@electric-eye.fr.zoreil.com>
References: <4EECA12DD88643FD9006350514D96C8E@realtek.com.tw>
 <20130328231955.GA26182@electric-eye.fr.zoreil.com>
 <83FC3118294143DC81063B29EF570FC1@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bowgotsai@google.com, "'Ryankao'" <ryankao@realtek.com>
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <83FC3118294143DC81063B29EF570FC1@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
> Francois Romieu [mailto:romieu@fr.zoreil.com] 
> [...]
> > Your description suggests that testing against the link 
> > partner ability to work at 10M instead of testing for
                                   ^^^^^^^^^^ -> "and"
> > tp->link_ok could be good enough.

As a policy we may assume that capabilities of the link partner won't
change after a link loss event - and there is currently no way we can
change this policy - but it won't always work as expected (especially
if "expected == automagically").

[...]
> Furthermore, should it not speed down without linking, even though the cable
> would be plugged after suspending or shutdowning?

I don't get your point. Can you reformulate ?

-- 
Ueimor

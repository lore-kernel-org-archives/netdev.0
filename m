From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping
	actions
Date: Wed, 05 Jul 2006 10:00:16 -0400
Message-ID: <1152108016.5199.39.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060704220550.406275000@postel.suug.ch> <1152064058.5199.12.camel@jzny2>
	 <1152106527.5199.23.camel@jzny2>  <20060705135447.GX14627@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:28385 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S964869AbWGEOAU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 10:00:20 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fy7vT-0001Xl-0w
	for netdev@vger.kernel.org; Wed, 05 Jul 2006 10:00:23 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060705135447.GX14627@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-07 at 15:54 +0200, Thomas Graf wrote:
> * jamal <hadi@cyberus.ca> 2006-07-05 09:35
> > Please resubmit this patch with changing -err to -1 (i.e a one liner)
> > I went back to about 2.6.10 and this is in there. I looked at my notes
> > and i cant see any reasoning to explain this. So it is a bug.
> 
> Fine, if you think that's better.
> 

It is consistent with the others. err is not used afterwards.

> > Is there a way to check whether this was a result of some other earlier
> > change or was always there?
> 
> It was there from the very beginning:
> 
> http://kernel.org/git/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=e96ec383ffef30843d34fe5766677dbffe0ca9a8

really fscked. So good eye.
For the future, can you tell me how to find to traceback that far?
Even within git: I know git-what-changed gives me logs on a file - but
how do i correlate that log to the exact change?

cheers,
jamal


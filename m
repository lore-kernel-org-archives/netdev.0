From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/3] [PKT_SCHED]: Fix error handling while dumping actions
Date: Wed, 5 Jul 2006 15:54:47 +0200
Message-ID: <20060705135447.GX14627@postel.suug.ch>
References: <20060704220504.787776000@postel.suug.ch> <20060704220550.406275000@postel.suug.ch> <1152064058.5199.12.camel@jzny2> <1152106527.5199.23.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:50393 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S964870AbWGENy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 09:54:28 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1152106527.5199.23.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* jamal <hadi@cyberus.ca> 2006-07-05 09:35
> Please resubmit this patch with changing -err to -1 (i.e a one liner)
> I went back to about 2.6.10 and this is in there. I looked at my notes
> and i cant see any reasoning to explain this. So it is a bug.

Fine, if you think that's better.

> Is there a way to check whether this was a result of some other earlier
> change or was always there?

It was there from the very beginning:

http://kernel.org/git/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=e96ec383ffef30843d34fe5766677dbffe0ca9a8

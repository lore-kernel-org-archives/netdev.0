From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v4 0/2] sctp: Consolidate and ratelimit deprecation
 warnings
Date: Tue, 31 Dec 2013 12:08:14 -0800
Message-ID: <1388520494.2259.27.camel@joe-AO722>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
	 <1387805383-21500-1-git-send-email-nhorman@tuxdriver.com>
	 <20131231.140000.463004971089550957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131231.140000.463004971089550957.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-12-31 at 14:00 -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 23 Dec 2013 08:29:41 -0500
> 
> > The SCTP protocol has several deprecation warnings in its setsockopt path that
> > can be triggered by unprivlidged users.  Since these are not ratelimited, we can
> > spam the logs quite easily here.  Since these are all deprecation warnings, and
> > that type of warning isn't uncommon in the rest of the kernel, lets make a
> > common pr_warn_deprecated macro to produce somewhat generalized ratelimited
> > deprecation warnings easily
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Series applied, thanks Neil.
> 
> Please consider Ben's suggestion to provide the offending command string
> in the log output.

If something like the printk extension described in this thread
http://thread.gmane.org/gmane.linux.kernel/1620126 is ever accepted,
then it should be pretty easy to add later.

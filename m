From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v4 0/2] sctp: Consolidate and ratelimit deprecation
 warnings
Date: Thu, 2 Jan 2014 09:31:35 -0500
Message-ID: <20140102143135.GA7526@hmsreliant.think-freely.org>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
 <1387805383-21500-1-git-send-email-nhorman@tuxdriver.com>
 <20131231.140000.463004971089550957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131231.140000.463004971089550957.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 31, 2013 at 02:00:00PM -0500, David Miller wrote:
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
> 
Of course, I'll take care of it this week after I dig through all the holiday
email.
Neil

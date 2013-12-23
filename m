From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3 0/2] sctp: Consolidate and ratelimit deprecation
 warnings
Date: Mon, 23 Dec 2013 08:19:32 -0500
Message-ID: <20131223131931.GA20864@hmsreliant.think-freely.org>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
 <1387297199-14363-1-git-send-email-nhorman@tuxdriver.com>
 <20131222.175659.1156282573702420627.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131222.175659.1156282573702420627.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 22, 2013 at 05:56:59PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 17 Dec 2013 11:19:57 -0500
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
> Neil, I really wish you would CC: netdev on all of the patches in the
> series.  Otherwise only some of them end up in patchwork, and this makes
> a lot more work for me if I want to actually apply this, which I do.
> 
> Please resubmit this properly, thanks.
> 

Will do, thanks.
Neil

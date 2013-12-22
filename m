From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] sctp: Consolidate and ratelimit deprecation
 warnings
Date: Sun, 22 Dec 2013 17:56:59 -0500 (EST)
Message-ID: <20131222.175659.1156282573702420627.davem@davemloft.net>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
	<1387297199-14363-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, vyasevich@gmail.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387297199-14363-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 17 Dec 2013 11:19:57 -0500

> The SCTP protocol has several deprecation warnings in its setsockopt path that
> can be triggered by unprivlidged users.  Since these are not ratelimited, we can
> spam the logs quite easily here.  Since these are all deprecation warnings, and
> that type of warning isn't uncommon in the rest of the kernel, lets make a
> common pr_warn_deprecated macro to produce somewhat generalized ratelimited
> deprecation warnings easily
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Neil, I really wish you would CC: netdev on all of the patches in the
series.  Otherwise only some of them end up in patchwork, and this makes
a lot more work for me if I want to actually apply this, which I do.

Please resubmit this properly, thanks.

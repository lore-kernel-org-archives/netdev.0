From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v4 0/2] sctp: Consolidate and ratelimit deprecation
 warnings
Date: Mon, 23 Dec 2013 22:55:16 +0000
Message-ID: <1387839316.1635.8.camel@bwh-desktop.uk.level5networks.com>
References: <1387205049-22752-1-git-send-email-nhorman@tuxdriver.com>
	 <1387805383-21500-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-sctp@vger.kernel.org>, Vlad Yasevich <vyasevich@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1387805383-21500-1-git-send-email-nhorman@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-12-23 at 08:29 -0500, Neil Horman wrote:
> The SCTP protocol has several deprecation warnings in its setsockopt path that
> can be triggered by unprivlidged users.  Since these are not ratelimited, we can
> spam the logs quite easily here.  Since these are all deprecation warnings, and
> that type of warning isn't uncommon in the rest of the kernel, lets make a
> common pr_warn_deprecated macro to produce somewhat generalized ratelimited
> deprecation warnings easily
[...]

No objection to these changes, but I think deprecation warnings should
log at least the command name and maybe also the pid of the caller.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

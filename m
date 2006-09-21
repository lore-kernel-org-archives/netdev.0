From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/7] d80211:  add SIOCSIWTXPOW, SIOCGIWTXPOW,
 SIOCSIWPOWER and SIOCGIWPOWER
Date: Fri, 22 Sep 2006 00:13:32 +0200
Message-ID: <20060922001332.7ea0d30a@logostar.upir.cz>
References: <44F355DE.3000206@linux.intel.com>
	<20060921183040.12d679f2@logostar.upir.cz>
	<4512C133.7010509@linux.intel.com>
	<20060921203347.44d66563@logostar.upir.cz>
	<4512EE8D.708@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49598 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751680AbWIUWNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 18:13:39 -0400
To: mabbas <mabbas@linux.intel.com>
In-Reply-To: <4512EE8D.708@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 21 Sep 2006 12:57:01 -0700, mabbas wrote:
> if the user set txpoer using iwconfig command, the driver will clap all 
> txpower to this
> value for all available channels if channels original txpower is higher 
> than txpower value.

Looks like a job for the stack.

If the stack takes care about that and always pass the correct value to a
driver, is there still a reason for the driver to know where the request
originated from?

 Jiri

-- 
Jiri Benc
SUSE Labs

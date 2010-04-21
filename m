From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ehea: error handling improvement
Date: Tue, 20 Apr 2010 19:16:02 -0700 (PDT)
Message-ID: <20100420.191602.228303800.davem@davemloft.net>
References: <4BCC47AB.2090600@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: osstklei@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BCC47AB.2090600@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Klein <osstklei@de.ibm.com>
Date: Mon, 19 Apr 2010 14:08:11 +0200

> Reset a port's resources only if they're actually in an error state
> 
> Signed-off-by: Thomas Klein <tklein@de.ibm.com>
> ---
> 
> Patch created against 2.6.34-rc4

There are several problems with these patches:

1) They are corrupted by your email client, lines unchanged
   begin with one space character instead of two.  Therefore
   even 'patch' wouldn't accept these changes.

2) The double slash in the patch file paths make git not
   accept the change.  Please don't put double-slashes in
   your patch paths as that canonically means "/".

3) These are not appropriate for net-2.6 as we are deep in
   the -rcX series at this point and only the most diabolical
   bug fixes are appropriate.  Therefore, please generate these
   against net-next-2.6, thanks.

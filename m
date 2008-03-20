From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [2.6.25-rc5-mm1] regression: cannot run Postfix sendmail command as non-root
Date: Thu, 20 Mar 2008 09:26:35 +0100
Message-ID: <939d53060803200126k563b9ae7l7197dea4e96ba1ed@mail.gmail.com>
References: <47D98510.60801@imap.cc>
	 <939d53060803191052o2f43b75cu426d51f9f24e2a46@mail.gmail.com>
	 <20080319141608.ede86a86.akpm@linux-foundation.org>
	 <20080319.154947.78332548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, tilman@imap.cc,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org, dlezcano@fr.ibm.com,
	xemul@openvz.org, rjw@sisk.pl, ebiederm@xmission.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:18212 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753306AbYCTI0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 04:26:38 -0400
Received: by rv-out-0910.google.com with SMTP id k20so433655rvb.1
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 01:26:36 -0700 (PDT)
In-Reply-To: <20080319.154947.78332548.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2008 at 11:49 PM, David Miller <davem@davemloft.net> wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
>  Date: Wed, 19 Mar 2008 14:16:08 -0700
>
>
>  > Although this is advertised as a 2.6.25-rc5-mm1 problem, I assume the
>  > regression is also in mainline? 2.6.25-rc6?
>
>  It is in 2.6.25-rc6, correct.
>
>  If Pavel or someone else doesn't produce a good fix soon
>  I'll revert the guilty change as this bug is worse than
>  the problem that changeset fixes.

Andre Noll sent a patch to LKML, acked by Pavel:

"Fix permissions of /proc/net"
http://thread.gmane.org/gmane.linux.kernel/655148

Benjamin

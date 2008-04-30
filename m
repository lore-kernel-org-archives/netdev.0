From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] net: ipv6 build fix
Date: Wed, 30 Apr 2008 23:29:22 +0200
Message-ID: <20080430212922.GA3031@elte.hu>
References: <20080430.013138.157977693.davem@davemloft.net> <20080430203839.GA19203@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:36137 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760681AbYD3V3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 17:29:42 -0400
Content-Disposition: inline
In-Reply-To: <20080430203839.GA19203@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> this fix here is just a quick guess - i _suspect_ that 
> do_ipv6_getsockopt() will just DTRT and return -EINVAL but i havent 
> checked. It obviously solves the build issue.

i see now that it's a mismerge:

  http://marc.info/?l=linux-netdev&m=120956601217678&w=2

	Ingo

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] ipv6: Create module parameter for use_tempaddr
Date: Tue, 13 Sep 2011 16:04:19 -0400 (EDT)
Message-ID: <20110913.160419.1722808201908218942.davem@davemloft.net>
References: <20110912212011.7C65B2041D@glenhelen.mtv.corp.google.com>
	<87r53ks2w3.fsf@nemi.mork.no>
	<CAMcMvshXgKCpwLFPzUWvmacTuqmSEjDfPgvZU2BHeC+WcXRH0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, netdev@vger.kernel.org
To: pstew@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932421Ab1IMUFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2011 16:05:31 -0400
In-Reply-To: <CAMcMvshXgKCpwLFPzUWvmacTuqmSEjDfPgvZU2BHeC+WcXRH0A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Stewart <pstew@chromium.org>
Date: Tue, 13 Sep 2011 12:56:28 -0700

> However, I'm not yet willing to accept the claim that ipv6 cannot be
> used as a module unless the rest of the system is painstakingly
> crafted to close any races between addrconf, sysctl and other
> IPv6-using processes.  That strikes me as far too brittle.

Most distributions are moving to building ipv6 statically into the
kernel, largely because of the issues described here.

From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCHSET net-next v3 00/07] Support for byte queue limits on various drivers
Date: Sun, 20 Oct 2013 14:13:28 -0700
Message-ID: <87iowrtzlz.fsf@tassilo.jf.intel.com>
References: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17565 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751824Ab3JTVN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Oct 2013 17:13:29 -0400
In-Reply-To: <1382296991-20289-1-git-send-email-milky-kernel@mcmilk.de> (Tino
	Reichardt's message of "Sun, 20 Oct 2013 21:23:04 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tino Reichardt <milky-kernel@mcmilk.de> writes:
>
> Since not all of them are fully tested by now, I added an bql_disable
> module parameter, which can be used to disable the BQL code.
>
> "if (likely(bql_disable == false))" was replaced by
> "if (unlikely(bql_disable))" ...

If it's untested it should probably be disabled by default,
until someone tests it.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

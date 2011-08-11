From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: initialize variable ecn_ok in syncookies path
Date: Wed, 10 Aug 2011 22:00:34 -0700 (PDT)
Message-ID: <20110810.220034.1867514011580098205.davem@davemloft.net>
References: <1313002284-2362-1-git-send-email-mikew@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mikew@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab1HKFF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 01:05:26 -0400
In-Reply-To: <1313002284-2362-1-git-send-email-mikew@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Waychison <mikew@google.com>
Date: Wed, 10 Aug 2011 11:51:24 -0700

> Using a gcc 4.4.3, warnings are emitted for a possibly uninitialized use
> of ecn_ok.
> 
> This can happen if cookie_check_timestamp() returns due to not
> having seen a timestamp.  Defaulting to ecn off seems like a
> reasonable thing to do in this case, so initialized ecn_ok to false.
> 
> Signed-off-by: Mike Waychison <mikew@google.com>

Applied, thanks Mike.

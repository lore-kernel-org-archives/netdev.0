From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] soreuseport: fix merge conflict in tcp bind
Date: Wed, 24 Feb 2016 13:38:55 -0500 (EST)
Message-ID: <20160224.133855.130250091133766630.davem@davemloft.net>
References: <1456155929-2708-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55720 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbcBXSjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 13:39:08 -0500
In-Reply-To: <1456155929-2708-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Mon, 22 Feb 2016 10:45:29 -0500

> From: Craig Gallek <kraig@google.com>
> 
> One of the validation checks for the new array-based TCP SO_REUSEPORT
> validation was unintentionally dropped in ea8add2b1903.  This adds it back.
> 
> Lack of this check allows the user to allocate multiple sock_reuseport
> structures (leaking all but the first).
> 
> Fixes: ea8add2b1903 ("tcp/dccp: better use of ephemeral ports in bind()")
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied, thanks Craig.

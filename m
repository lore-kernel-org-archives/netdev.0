From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] ipvlan: Fix failure path in dev registration
 during link creation
Date: Wed, 27 Apr 2016 14:57:42 -0400 (EDT)
Message-ID: <20160427.145742.1732984000881376610.davem@davemloft.net>
References: <1461782259-10806-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53182 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913AbcD0S5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 14:57:44 -0400
In-Reply-To: <1461782259-10806-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 27 Apr 2016 11:37:39 -0700

> While fixing this issue I noticed another issue of missing unregister
> in case of failure, so adding it to the fix which is similar to the
> macvlan fix by Francesco in SHA1:308379607548524b8d86dbf20134681024935e0b

This is not the correct way to refer to commits.

You should specify, exactly, 12 digits of the SHA1 value, followed by
a space, followed by the header line text of that commit contained in
parenthesis and double quotes, like how Fixes: tags specify commits.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] Tunneling fixes
Date: Sun, 20 Mar 2016 16:33:58 -0400 (EDT)
Message-ID: <20160320.163358.86760909016669242.davem@davemloft.net>
References: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jesse@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbcCTUd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2016 16:33:59 -0400
In-Reply-To: <1458405122-12565-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@kernel.org>
Date: Sat, 19 Mar 2016 09:31:59 -0700

> This series fixes a problem that was reported where encapsulated packets
> do not have their encapsulation offload markers stripped off when being
> decapsulated. This causes a significant performance drop if the packets
> are later retransmitted.
> 
> Fixing this revealed two other bugs which are also addressed as prerequisites:
>  * GRO can aggregate packets for multiple layers of encapsulation which the
>    stack cannot properly handle.
>  * IPIP packets which are combined by GRO are not marked properly with their
>    GSO type.
> 
> Note that this is based off the net-next tree as the current target for
> bug fixes.
> 
> v2: No code changes, just additional information in commit messages and
>     a new cover letter.

Applied, thanks for respinning this Jesse.

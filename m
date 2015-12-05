From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Sat, 05 Dec 2015 18:16:03 -0500 (EST)
Message-ID: <20151205.181603.662890672788412924.davem@davemloft.net>
References: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, therbert@google.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613AbbLEXQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 18:16:05 -0500
In-Reply-To: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri,  4 Dec 2015 13:54:03 +0100

> Commit 3511494ce2f3d ("vxlan: Group Policy extension") changed definition of
> VXLAN_HF_RCO from 0x00200000 to BIT(24). This is obviously incorrect. It's
> also in violation with the RFC draft.
> 
> Fixes: 3511494ce2f3d ("vxlan: Group Policy extension")
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> This code is, unfortunately, in the tree since 4.0. Not sure whether we can
> change it now. On the other hand, we're in violation with the RFC draft and
> collide with VXLAN-GPE flags assignment which defines this bit as OAM flag.
> 
> Opinions welcome, especially by Tom and Thomas.

Applied and queued up for -stable.

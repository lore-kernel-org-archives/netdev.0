From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net 0/6] OVS conntrack fixes for net
Date: Wed, 07 Oct 2015 05:03:37 -0700 (PDT)
Message-ID: <20151007.050337.842446807576178595.davem@davemloft.net>
References: <1444154401-18029-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: joestringer@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbbJGLrx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:47:53 -0400
In-Reply-To: <1444154401-18029-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joestringer@nicira.com>
Date: Tue,  6 Oct 2015 10:59:55 -0700

> The userspace side of the Open vSwitch conntrack changes is currently
> undergoing review, which has highlighted some minor bugs in the existing
> conntrack implementation in the kernel, as well as pointing out some
> future-proofing that can be done on the interface to reduce the need for
> additional compatibility code in future.
> 
> The biggest changes here are to the userspace API for the ct_state match
> field and the CT action. This series proposes to firstly extend the ct_state
> match field to 32 bits, ensuring to reject any currently unsupported bits.
> Secondly, rather than representing CT action flags within a 32-bit field,
> simply use a netlink attribute as presence of the single flag that is
> defined today. This also serves to reject unsupported ct action flag bits.
> 
> v4: Use 12-character abbreviated hashes in commit messages.
> v3: Fully acked.
> v2: Address minor style feedback, add acks.
> v1: Initial post.

Series applied, thanks Joe.

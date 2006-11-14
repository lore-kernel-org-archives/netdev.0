From: David Miller <davem@davemloft.net>
Subject: Re: [patch] fix up generic csum_ipv6_magic function prototype
Date: Mon, 13 Nov 2006 16:16:56 -0800 (PST)
Message-ID: <20061113.161656.90118004.davem@davemloft.net>
References: <20061109072216.GL29920@ftp.linux.org.uk>
	<20061108.235548.12921799.davem@davemloft.net>
	<20061113085223.GR29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kenneth.w.chen@intel.com, akpm@osdl.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:19675
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933227AbWKNAQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 19:16:48 -0500
To: viro@ftp.linux.org.uk
In-Reply-To: <20061113085223.GR29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@ftp.linux.org.uk>
Date: Mon, 13 Nov 2006 08:52:23 +0000

> The first question is in the types we are using for length.  OK,
> csum_tcpudp_...() is a special case; there we want u16 and unless
> there's a reason _not_ to do so on sparc, I'd rather convert it
> to the same thing.

That's fine.

> csum_partial_copy_fromuser():  Can die, only 3 targets have its rudiment
> and nothing in the tree uses it.  ACK?

ACK.

> csum_partial_copy().  Rare alias for csum_partial_copy_nocheck().  Can die;
> all instances simply should be renamed to csum_partial_copy_nocheck.  ACK?

ACK.

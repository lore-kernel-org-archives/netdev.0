From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] be2net: fix vfs enumeration
Date: Mon, 01 Oct 2012 16:46:36 -0400 (EDT)
Message-ID: <20121001.164636.2110489341405301314.davem@davemloft.net>
References: <1349092615-31894-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	sfr@canb.auug.org.au
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755978Ab2JAUqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:46:38 -0400
In-Reply-To: <1349092615-31894-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Mon,  1 Oct 2012 13:56:55 +0200

> Current VFs enumeration algorithm used in be_find_vfs does not take domain
> number into the match. The match found in igb/ixgbe is more elegant and
> safe.
> 
> This 2nd version uses pci_physfn instead of checking dev->physfn directly.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied.

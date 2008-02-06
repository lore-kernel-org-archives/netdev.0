From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 07/24 for-2.6.25] DM9000: Add initial ethtool support
Date: Wed, 6 Feb 2008 22:52:54 +0100
Message-ID: <20080206215254.GA3212@electric-eye.fr.zoreil.com>
References: <20080205000159.432081941@fluff.org.uk> <20080205000815.759244139@fluff.org.uk> <20080205225045.GA12258@electric-eye.fr.zoreil.com> <20080206220334.GE15407@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Dooks <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36995 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756867AbYBFWLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 17:11:13 -0500
Content-Disposition: inline
In-Reply-To: <20080206220334.GE15407@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Dooks <ben@fluff.org> :
[...]
> The next patch in the series changes the locking.

Do you mean patch #08 ?

If so it does not fix this bug: the very first line in
dm9000_phy_read includes a spinlock statement.

-- 
Ueimor

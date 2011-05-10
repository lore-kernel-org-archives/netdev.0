From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [PATCH] linux-firmware: bnx2: Update firmware and version
Date: Wed, 11 May 2011 00:10:54 +0100
Message-ID: <1305069055.30435.99.camel@i7.infradead.org>
References: <1305065779-26976-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38804 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197Ab1EJXK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 19:10:56 -0400
In-Reply-To: <1305065779-26976-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-10 at 15:16 -0700, Michael Chan wrote:
> upstream kernel commit dc187cb381f1bceb30498861ece510245c43ed9f

This stuff should no longer get changed in the upstream kernel; what's
there is *historical* and due for deletion.

> Update 5709 mips firmware to 6.2.1a to fix iSCSI performance
> regression.  There was an unnecessary context read in the fast path
> affecting performance. 

Is this update not ABI compatible? You have changed the soname of the
firmware... was that intentional?

-- 
dwmw2


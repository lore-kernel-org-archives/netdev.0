From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/12] forcedeth: ring access
Date: Thu, 18 Jan 2007 21:51:14 -0500
Message-ID: <45B03222.9030802@pobox.com>
References: <45A3DF2F.10202@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47562 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932860AbXASCvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 21:51:25 -0500
To: Ayaz Abdulla <aabdulla@nvidia.com>
In-Reply-To: <45A3DF2F.10202@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> This patch modifys ring access by using pointers. This avoids computing 
> the current index and avoids accessing the base address of the rings.
> 
> Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>

ACK patches 1-9.

Applied patches 1-4 successfully, patch #5 failed to apply.  Please 
resend patches 5+ against netdev-2.6.git#upstream.

Also, git-am (the git component used to apply yours and others' patches) 
complains that your patches have spaces prior to the tab indentations. 
Fixing that in patches 5+, or appending a final whitespace cleanup 
patch, would be appreciated.

	Jeff




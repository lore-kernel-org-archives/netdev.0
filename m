From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 8/8] forcedeth boot delay fix
Date: Fri, 23 Nov 2007 21:00:09 -0500
Message-ID: <474785A9.3000207@garzik.org>
References: <200711212302.lALN2ww0013673@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com, astinus@gentoo.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41864 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753381AbXKXCAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 21:00:12 -0500
In-Reply-To: <200711212302.lALN2ww0013673@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> Fix a long boot delay in the forcedeth driver.  During initialization, the
> timeout for the handshake between mgmt unit and driver can be very long. 
> The patch reduces the timeout by eliminating a extra loop around the
> timeout logic.
> 
> Addresses http://bugzilla.kernel.org/show_bug.cgi?id=9308
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> Cc: Alex Howells <astinus@gentoo.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied #upstream-fixes



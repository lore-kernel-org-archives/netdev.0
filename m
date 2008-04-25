From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 6/9] forcedeth: new backoff implementation
Date: Fri, 25 Apr 2008 02:03:45 -0400
Message-ID: <48117441.8070005@garzik.org>
References: <200804182050.m3IKoird014836@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58554 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755044AbYDYGDr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:03:47 -0400
In-Reply-To: <200804182050.m3IKoird014836@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Ayaz Abdulla <aabdulla@nvidia.com>
> 
> This patch adds support for a new backoff algorithm for half duplex supported
> in newer hardware.  The old method is will be designated as legacy mode.
> 
> Re-seeding random values for the backoff algorithms are performed when a
> transmit has failed due to a maximum retry count (1 to 15, where max is
> considered the wraparound case of 0).
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

applied



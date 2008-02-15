From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000e: Fix CRC stripping in hardware context bug
Date: Fri, 15 Feb 2008 10:53:41 -0500
Message-ID: <47B5B585.4070107@garzik.org>
References: <20080212232024.13842.10804.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johan.andersson@transmode.se,
	andy@greyhouse.net, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52917 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526AbYBOPxp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 10:53:45 -0500
In-Reply-To: <20080212232024.13842.10804.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> CRC stripping was only correctly enabled for packet split recieves
> which is used when receiving jumbo frames. Correctly enable SECRC
> also for normal buffer packet receives.
> 
> Tested by Andy Gospodarek and Johan Andersson, see bugzilla #9940.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000e/netdev.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)

applied



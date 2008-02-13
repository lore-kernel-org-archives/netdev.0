From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH] e1000e: Fix CRC stripping in hardware context bug
Date: Tue, 12 Feb 2008 21:33:00 -0500
Message-ID: <20080213023300.GG856@gospo.usersys.redhat.com>
References: <20080212232024.13842.10804.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	johan.andersson@transmode.se, andy@greyhouse.net,
	e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33121 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753752AbYBMCdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 21:33:24 -0500
Content-Disposition: inline
In-Reply-To: <20080212232024.13842.10804.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 12, 2008 at 03:20:24PM -0800, Auke Kok wrote:
> CRC stripping was only correctly enabled for packet split recieves
> which is used when receiving jumbo frames. Correctly enable SECRC
> also for normal buffer packet receives.
> 
> Tested by Andy Gospodarek and Johan Andersson, see bugzilla #9940.
> 

This works well on my systems.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>


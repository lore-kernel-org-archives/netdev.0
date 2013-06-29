From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 8/8] alx: remove WoL support
Date: Sat, 29 Jun 2013 21:40:45 +0200
Message-ID: <1372534845.17242.0.camel@jlt4.sipsolutions.net>
References: <1372526600-15934-1-git-send-email-johannes@sipsolutions.net>
	 <1372526600-15934-9-git-send-email-johannes@sipsolutions.net>
	 <20130629191248.GA10570@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:58757 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773Ab3F2Tkt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 15:40:49 -0400
In-Reply-To: <20130629191248.GA10570@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > -	.driver.pm   = ALX_PM_OPS,
> >  };
> 
> Not sure but doesn't that mean the driver breaks after suspend?
> I think you removed too much, not just WOL support but all pm handling.

*sigh*, yes, you're probably right. Probably should stop/restart if the
interface is up. I'll try to poke at it tomorrow.

johannes

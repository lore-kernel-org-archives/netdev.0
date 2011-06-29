From: David Miller <davem@davemloft.net>
Subject: Re: Remove over-broad module alias from zaurus.
Date: Wed, 29 Jun 2011 06:09:52 -0700 (PDT)
Message-ID: <20110629.060952.715854888802058406.davem@davemloft.net>
References: <20110627204207.GB5341@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755867Ab1F2NJ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2011 09:09:57 -0400
In-Reply-To: <20110627204207.GB5341@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Mon, 27 Jun 2011 13:42:07 -0700

> This module and a bunch of dependancies are getting loaded on several
> of laptops I have (probably picking up the mobile broadband device),
> that have nothing to do with zaurus. Matching by class without
> any vendor/device pair isn't the right thing to do here, as it
> will prevent any other driver from correctly binding to it.
> (Or in the absense of a driver, will just waste time & memory by
>  unnecessarily loading modules)
> 
> Signed-off-by: Dave Jones <davej@redhat.com>

Applied, thanks.

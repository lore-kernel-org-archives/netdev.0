From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [2/2] Remove some unnecessary gotos in
 established_get_first()
Date: Wed, 30 Jan 2008 05:46:07 -0800 (PST)
Message-ID: <20080130.054607.132299942.davem@davemloft.net>
References: <20080130901.138686634@suse.de>
	<20080130080110.35B691B416F@basil.firstfloor.org>
	<200801300925.12397.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oliver@neukum.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38933
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751464AbYA3Nps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 08:45:48 -0500
In-Reply-To: <200801300925.12397.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oliver@neukum.org>
Date: Wed, 30 Jan 2008 09:25:12 +0100

> Now suppose somebody needs to change locking. He'll have to convert
> it back. IMHO a conditional return is worse than "goto clearly_named_label"

I totally agree.

From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] isdn: make sure strings are null terminated
Date: Tue, 29 Nov 2011 18:40:00 -0500 (EST)
Message-ID: <20111129.184000.916136138216921151.davem@davemloft.net>
References: <20111123064204.GA6871@elgon.mountain>
	<1322031811.1298.38.camel@edumazet-laptop>
	<20111124124149.GH3195@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, isdn@linux-pingi.de,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755941Ab1K2XkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:40:10 -0500
In-Reply-To: <20111124124149.GH3195@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 24 Nov 2011 15:41:49 +0300

> These strings come from the user.  We strcpy() them inside
> cf_command() so we should check that they are NULL terminated and
> return an error if not.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: use strnlen() instead of strlen().

Applied.

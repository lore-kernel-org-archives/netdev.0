From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: Fix a problem when dumping the default IPv6
 static labels
Date: Fri, 27 Jun 2008 20:12:46 -0700 (PDT)
Message-ID: <20080627.201246.236972639.davem@davemloft.net>
References: <20080625202913.19613.5413.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50617
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752053AbYF1DMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:12:45 -0400
In-Reply-To: <20080625202913.19613.5413.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 25 Jun 2008 16:29:13 -0400

> There is a missing "!" in a conditional statement which is causing entries to
> be skipped when dumping the default IPv6 static label entries.  This can be
> demonstrated by running the following:
> 
>  # netlabelctl unlbl add default address:::1 \
>                                  label:system_u:object_r:unlabeled_t:s0
>  # netlabelctl -p unlbl list
> 
> ... you will notice that the entry for the IPv6 localhost address is not
> displayed but does exist (works correctly, causes collisions when attempting
> to add duplicate entries, etc.).
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Patch applied, thanks Paul.

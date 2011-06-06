From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 12:22:17 -0700 (PDT)
Message-ID: <20110606.122217.2183968212149987796.davem@davemloft.net>
References: <1306273128.8149.1444.camel@tardy>
	<20110604.132940.2214949964968775365.davem@davemloft.net>
	<1307380132.8149.2718.camel@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab1FFTWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 15:22:21 -0400
In-Reply-To: <1307380132.8149.2718.camel@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Mon, 06 Jun 2011 10:08:52 -0700

> Mode-rr bonding reorders TCP segments all the time. 

Oh well, then don't use this if you care about performance at all.
And therefore it's not even worth considering for our RPS fragment
cache.

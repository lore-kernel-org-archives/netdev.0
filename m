From: David Miller <davem@davemloft.net>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 02:12:09 -0800 (PST)
Message-ID: <20070220.021209.39159087.davem@davemloft.net>
References: <200702191913.08125.dada1@cosmosbay.com>
	<20070220092523.GA6238@2ka.mipt.ru>
	<200702201104.16200.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, akepner@sgi.com, linux@horizon.com,
	netdev@vger.kernel.org, bcrl@kvack.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46535
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932737AbXBTKMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 05:12:10 -0500
In-Reply-To: <200702201104.16200.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 20 Feb 2007 11:04:15 +0100

> Using a jenkin's hash permits a better hash distribution for a litle
> cpu cost.  I will post later a distribution simulation based on the
> data gathered from the same real server.

Actually someone (I think it was Evgeniy in fact) made such
comparisons and found in his studies that not only does the current
ehash xor hash function distribute about as well as jenkins, it's
significantly cheaper to calculate :-)

If you find jenkins is better, great, but I hope it works that
way for many workloads.

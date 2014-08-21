From: David Miller <davem@davemloft.net>
Subject: Re: Performance regression on kernels 3.10 and newer
Date: Thu, 21 Aug 2014 16:51:36 -0700 (PDT)
Message-ID: <20140821.165136.653027228264864005.davem@davemloft.net>
References: <53ED4354.9090904@intel.com>
	<20140814.162024.2218312002979492106.davem@davemloft.net>
	<53EE4023.6080902@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44227 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbaHUXvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 19:51:38 -0400
In-Reply-To: <53EE4023.6080902@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Fri, 15 Aug 2014 10:15:15 -0700

> This is one of the reasons why I keep asking if someone can tell me
> what the use case is for this where it performs well.

It allows the TCP connection to be paced by the process scheduler's
ability to put the thread doing the I/O on a cpu.

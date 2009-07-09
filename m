From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Hitting slab BUG with bridging/cxgb3 on 2.6.31-rc2
Date: Wed, 08 Jul 2009 17:32:31 -0700
Message-ID: <adaljmyzof4.fsf@cisco.com>
References: <adaeisq23rq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:5092 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755331AbZGIAcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 20:32:32 -0400
Received: from sj-core-5.cisco.com (sj-core-5.cisco.com [171.71.177.238])
	by sj-dkim-4.cisco.com (8.12.11/8.12.11) with ESMTP id n690WWx1012375
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 17:32:32 -0700
Received: from xbh-sjc-221.amer.cisco.com (xbh-sjc-221.cisco.com [128.107.191.63])
	by sj-core-5.cisco.com (8.13.8/8.14.3) with ESMTP id n690WWfJ010064
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 00:32:32 GMT
In-Reply-To: <adaeisq23rq.fsf@cisco.com> (Roland Dreier's message of "Wed, 08
	Jul 2009 15:44:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2.6.30 seems OK -- wasn't able to hit this bug.

Commencing the bisection... will take a while, since triggering the bug
is slow and rebooting this box is slow as well too (since it has a long
BIOS sequence...)

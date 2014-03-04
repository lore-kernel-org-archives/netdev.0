From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] Deadlock on sk->sk_lock.slock
Date: Tue, 04 Mar 2014 13:48:11 -0500 (EST)
Message-ID: <20140304.134811.86791174090638790.davem@davemloft.net>
References: <771471B8871B5044A6CA7CCD9C26EEE10117E265C59B@xmail2.se.axis.com>
	<1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lars.persson@axis.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35766 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755048AbaCDSsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 13:48:13 -0500
In-Reply-To: <1393942583.26794.107.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 04 Mar 2014 06:16:23 -0800

> Could you try following hack/patch ?

Eric, if you do fix it like this (I don't mind), please use mnenomics
for the various lock state values.

Thanks.

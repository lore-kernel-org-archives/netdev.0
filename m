From: David Miller <davem@davemloft.net>
Subject: Re: inet_gifconf question
Date: Sat, 15 Sep 2012 00:01:38 -0400 (EDT)
Message-ID: <20120915.000138.66562707919088586.davem@davemloft.net>
References: <20120914230935.65a3769b@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab2IOEBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Sep 2012 00:01:39 -0400
In-Reply-To: <20120914230935.65a3769b@pyramind.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Fri, 14 Sep 2012 23:09:35 +0100

> Can anyone tell me what inet_gifconf is meant to be doing with the test
> of ifa->ifa_label against NULL when ifa->ifa_label is an array ?

It wasn't always an array, and this spot got missed during the
conversion it seems.

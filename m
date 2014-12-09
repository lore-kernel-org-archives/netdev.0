From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/4] ipvlan: play well with macvlan device
Date: Tue, 09 Dec 2014 16:10:43 -0500 (EST)
Message-ID: <20141209.161043.1587450996273220844.davem@davemloft.net>
References: <1417909999-13234-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbaLIVKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 16:10:46 -0500
In-Reply-To: <1417909999-13234-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat,  6 Dec 2014 15:53:19 -0800

> If a device is already a macvlan port then refuse to use it as
> an ipvlan port in the early stage of port creation.
> 
> 	thost1:~# ip link add link eth0 mvl0 type macvlan
> 	thost1:~# echo $?
> 	0
> 	thost1:~# ip link add link eth0 ipvl0 type ipvlan
> 	RTNETLINK answers: Device or resource busy
> 	thost1:~# echo $?
> 	2
> 	thost1:~#
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>

Applied.

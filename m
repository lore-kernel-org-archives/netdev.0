From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: Jumbo frame question...
Date: Sat, 25 Jul 2009 08:34:34 -0400
Message-ID: <200907250834.34175.rgetz@blackfin.uclinux.org>
References: <200907241141.55097.rgetz@blackfin.uclinux.org> <200907241421.55986.rgetz@blackfin.uclinux.org> <4A6A07E5.9080705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Rick Jones" <rick.jones2@hp.com>,
	"David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:8322 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbZGYMbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 08:31:19 -0400
In-Reply-To: <4A6A07E5.9080705@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri 24 Jul 2009 15:13, Eric Dumazet pondered:
> I guess your tcpdump is fooled by gso settings... Did you tried
> # ethtool -K eth0 gso off 

No -- that was the problem - my hardware trying to be too smart for my software...

Thanks for the help - sorry for the noise.

-Robin

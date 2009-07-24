From: David Miller <davem@davemloft.net>
Subject: Re: Jumbo frame question...
Date: Fri, 24 Jul 2009 09:32:43 -0700 (PDT)
Message-ID: <20090724.093243.201296391.davem@davemloft.net>
References: <200907241141.55097.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rgetz@blackfin.uclinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39630
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751026AbZGXQch (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 12:32:37 -0400
In-Reply-To: <200907241141.55097.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robin Getz <rgetz@blackfin.uclinux.org>
Date: Fri, 24 Jul 2009 11:41:55 -0400

> Should a gigabit card, configured as 100, be sending jumbo UDP frames?
> 
> My understanding, is no - this is a spec violation..

There is nothing wrong with supporting jumbo frames
when the speed is lower than 1GB.

If you configure the MTU to be jumbo size, it should
be no surprise to you that this is what gets used.

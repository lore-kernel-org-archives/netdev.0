From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 01:37:38 -0700 (PDT)
Message-ID: <20090831.013738.127727614.davem@davemloft.net>
References: <20090831053026.GA5005@ff.dom.local>
	<20090830.223239.185830289.davem@davemloft.net>
	<200908311118.43024.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59500
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751644AbZHaIhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 04:37:24 -0400
In-Reply-To: <200908311118.43024.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryschenko <denys@visp.net.lb>
Date: Mon, 31 Aug 2009 11:18:42 +0300

> 2.6.31-rc8 i got dmesg flooded. First message appearing even without patch, i 
> will make sure now what is a reason of that (i have HTB classes on ifb0, and 
> TBF on pppX).
> 
> [  155.199923] Attempt to kill tasklet from interrupt

We know the reasons for this message, it's an HTB regression and we're
working on it.

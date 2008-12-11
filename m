From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Phonet: ensure GPRS device does not go away during
 TX work
Date: Thu, 11 Dec 2008 00:33:23 -0800 (PST)
Message-ID: <20081211.003323.193691721.davem@davemloft.net>
References: <1228914929-26337-1-git-send-email-remi.denis-courmont@nokia.com>
	<20081210.152845.24693255.davem@davemloft.net>
	<200812111011.17891.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42699
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754564AbYLKIdW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 03:33:22 -0500
In-Reply-To: <200812111011.17891.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Thu, 11 Dec 2008 10:11:17 +0200

> Can I assume that scheduled work will be flushed sometime between
> ->stop and ->destructor then?

If you have a workqueue you can explicitly flush it in your
->stop() method.

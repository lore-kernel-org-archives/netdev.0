From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/9] net: moxart: use correct accessors for DMA memory
Date: Thu, 28 Jan 2016 17:58:05 +0100
Message-ID: <1907107.CbDFUn8Tsc@wuerfel>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de> <063D6719AE5E284EB5DD2968C1650D6D1CCCEDCE@AcuExch.aculab.com> <3468358.kXWNPLZEG9@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	"David S. Miller" <davem@davemloft.net>,
	=?ISO-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:55208 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965376AbcA1Q6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 11:58:45 -0500
In-Reply-To: <3468358.kXWNPLZEG9@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 January 2016 17:53:43 Arnd Bergmann wrote:
> 
> Makes sense. I looked at the ftmac100 driver, which is another driver
> for the same hardware, and it's also missing barriers. We should
> probably add them for both then.
> 

Nevermind. That one has write barriers, but no read barriers. I'm assuming
that this intentional and won't follow up with another patch for ftmac100.

	Arnd

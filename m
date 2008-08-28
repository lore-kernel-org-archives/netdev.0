From: David Miller <davem@davemloft.net>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 12:36:45 -0700 (PDT)
Message-ID: <20080828.123645.78561286.davem@davemloft.net>
References: <21915755.1327801219904892242.JavaMail.root@ouachita>
	<20080828072218.GI26610@one.firstfloor.org>
	<200808281948.52608.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, jmalicki@metacarta.com, johnpol@2ka.mipt.ru,
	dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com, sammy@sammy.net
To: denys@visp.net.lb
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754032AbYH1Tgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 15:36:50 -0400
In-Reply-To: <200808281948.52608.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denys Fedoryshchenko <denys@visp.net.lb>
Date: Thu, 28 Aug 2008 19:48:52 +0300

> So there is few good solutions available (IMHO):
> 1)Introduce some SO_REALTIMESTAMP (anyway even SO_TIMESTAMP not defined in any 
> standard) for banks and ntp folks, who need them. And even give them timespec 
> instead timeval, so they will be even more happy with resolution.
> 2)Provide sysctl,kernel boot, or even "build time" option for "banks" to have 
> high resolution(and expensive) SO_TIMESTAMP.

The performance hit hurts, but changing the default to lower
resolution after it having been high resolution for 10+ years
is a regression and something we really can't do.

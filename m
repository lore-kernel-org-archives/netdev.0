From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] bridge: STP timer management range checking
Date: Tue, 02 Sep 2008 16:41:30 -0700 (PDT)
Message-ID: <20080902.164130.156055373.davem@davemloft.net>
References: <48BB295A.6050200@vyatta.com>
	<20080901093827.24eec86f@lxorguk.ukuu.org.uk>
	<48BD6C8E.5060704@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alan@lxorguk.ukuu.org.uk, stephen.hemminger@vyatta.com,
	shemminger@vyatta.com, dusanc@gmail.com, romieu@fr.zoreil.com,
	hancockr@shaw.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38849
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754316AbYIBXlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 19:41:36 -0400
In-Reply-To: <48BD6C8E.5060704@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 02 Sep 2008 09:40:46 -0700

> Can one change the TCP maximum RTO to be smaller than specified in the specs?

We always min-clamp the RTO at RTO calculation time in order to be
compatible with BSD's coarse grained times.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] net: Batch inet_twsk_purge
Date: Thu, 03 Dec 2009 12:24:36 -0800 (PST)
Message-ID: <20091203.122436.239332194.davem@davemloft.net>
References: <1259843349-3810-7-git-send-email-ebiederm@xmission.com>
	<4B17BBC9.8070106@gmail.com>
	<m1ws14kwln.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca,
	dlezcano@fr.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753764AbZLCUYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 15:24:30 -0500
In-Reply-To: <m1ws14kwln.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 03 Dec 2009 05:36:52 -0800

> I think dccp may also need a inet_twsk_purge as well, but I couldn't
> figure out what it was doing with timewait sockets.

DCCP doesn't have time-wait sockets, it's more like UDP than TCP.

From: David Miller <davem@davemloft.net>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Mon, 31 Jul 2006 18:05:18 -0700 (PDT)
Message-ID: <20060731.180518.66061450.davem@davemloft.net>
References: <20060727200655.GA4586@2ka.mipt.ru>
	<44C930D5.9020704@oracle.com>
	<20060728052312.GB11210@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3233
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030375AbWHABGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 21:06:01 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060728052312.GB11210@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Fri, 28 Jul 2006 09:23:12 +0400

> I completely agree that existing kevent interface is not the best, so
> I'm opened for any suggestions.
> Should kevent creation/removing/modification be separated too?

I do not think so, object for these 3 operations are the same,
so there are no typing issues.

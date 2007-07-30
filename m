From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC]: napi_struct V4
Date: Mon, 30 Jul 2007 15:48:54 -0700 (PDT)
Message-ID: <20070730.154854.07455239.davem@davemloft.net>
References: <ada1wesy2eh.fsf@cisco.com>
	<20070728.223206.112621083.davem@davemloft.net>
	<ada7ioiszk7.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca, rusty@rustcorp.com.au
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757050AbXG3Wsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 18:48:55 -0400
In-Reply-To: <ada7ioiszk7.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier@cisco.com>
Date: Mon, 30 Jul 2007 08:04:24 -0700

> IPoIB can cope but it really seems like an unfortunate feature of
> these changes that we can't do something like what we have today,
> which imposes no overhead unless an event actually lands in the race
> window.

It is not a feature of these changes.

These races exist in the current code, it is a bug fix.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] TCP CUBIC Hystart fixes
Date: Mon, 14 Mar 2011 15:58:05 -0700 (PDT)
Message-ID: <20110314.155805.42792645.davem@davemloft.net>
References: <20110314175211.788224699@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43330
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932104Ab1CNW51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:57:27 -0400
In-Reply-To: <20110314175211.788224699@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 14 Mar 2011 10:52:11 -0700

> This is the merge of my patches and recent update Sangtae.
> It addresses the problems reported by Lucas Nussbaum that Hystart causes
> poor startup performance over links with lots of buffering.

Ok, I've applied all of this to net-2.6 and did test builds with HZ={100,250,1000}
on both sparc64 and x86.

I'll let it cook for a day or two before pushing it out to Linus.

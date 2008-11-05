From: David Miller <davem@davemloft.net>
Subject: Re: time for TCP ECN defaulting to on?
Date: Tue, 04 Nov 2008 23:29:20 -0800 (PST)
Message-ID: <20081104.232920.150683916.davem@davemloft.net>
References: <20081104.215839.132524253.davem@davemloft.net>
	<C27F8246C663564A84BB7AB343977242151F4B18B4@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@blueteddy.net, daniel.blueman@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49833
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750910AbYKEH3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 02:29:45 -0500
In-Reply-To: <C27F8246C663564A84BB7AB343977242151F4B18B4@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 4 Nov 2008 22:31:00 -0800

> Assuming ECE and CWR are set infrequently on TSO frames, we still
> benefit from hardware TSO most of the time.  Why is it the wrong
> thing to do?

I had forgotten about that aspect, and yes this is a
good tradeoff considering that.

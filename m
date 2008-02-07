From: David Miller <davem@davemloft.net>
Subject: Re: converting fore200e driver to use request_firmware()
Date: Wed, 06 Feb 2008 16:05:42 -0800 (PST)
Message-ID: <20080206.160542.07994571.davem@davemloft.net>
References: <200802070001.m1701o8E019626@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50943
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1765309AbYBGAFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 19:05:11 -0500
In-Reply-To: <200802070001.m1701o8E019626@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Date: Wed, 6 Feb 2008 19:01:50 -0500

> however, i ran into a little problem with the sbus interface.  what should
> i pass for 'struct device *' for an sbus device?

"&sdev->ofdev.dev" should work

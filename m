From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] E1000: Fix ifdown hang in git-2.6.24
Date: Fri, 24 Aug 2007 23:07:14 -0700 (PDT)
Message-ID: <20070824.230714.109888796.davem@davemloft.net>
References: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40409
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759125AbXHYGHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:07:15 -0400
In-Reply-To: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 23 Aug 2007 14:34:18 +0530

> Doing napi_disable twice hangs "ifdown" of the device. e1000_down is the
> common place to call napi_disable.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

Applied, thanks a lot.

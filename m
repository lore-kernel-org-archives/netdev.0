From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP FIN gets dropped prematurely, results in ack storm
Date: Tue, 01 May 2007 13:24:17 -0700 (PDT)
Message-ID: <20070501.132417.112596907.davem@davemloft.net>
References: <20070501175340.GD1751@kvack.org>
	<463780D8.2080105@psc.edu>
	<20070501191931.GF1751@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jheffner@psc.edu, johnpol@2ka.mipt.ru, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45373
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965211AbXEAUYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 16:24:18 -0400
In-Reply-To: <20070501191931.GF1751@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Tue, 1 May 2007 15:19:31 -0400

> On Tue, May 01, 2007 at 02:03:04PM -0400, John Heffner wrote:
> > Being liberal in what you accept is good to a point, but sometimes you 
> > have to draw the line.
> 
> True.  Still, both sides are doing completely the wrong thing in this case, 
> and I'd like to get an idea of the best way to prevent the ACK storm from 
> happenning.

You do it by fixing the broken 2.2.x system, you don't do it
by breaking 2.6.x to spit out FINs with different sequence
numbers which is absolutely wrong and will cause more problems
than it will solve.

Please drop even the thought of this patch, kthx.

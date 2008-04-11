From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH take2][NET_SCHED] cls_u32: refcounting fix for u32_delete()
Date: Fri, 11 Apr 2008 16:00:38 +0200
Message-ID: <47FF6F06.3000008@trash.net>
References: <20080411124519.GA2701@ff.dom.local> <47FF5FBF.6030802@trash.net> <20080411132304.GB2701@ff.dom.local> <47FF662B.2040302@trash.net> <20080411134818.GA3776@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55482 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759038AbYDKOAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 10:00:43 -0400
In-Reply-To: <20080411134818.GA3776@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> [NET_SCHED] cls_u32: refcounting fix for u32_delete()
> 
> Deleting of nonroot hnodes mostly doesn't work in u32_delete():
> refcnt == 1 is expected, but such hnodes' refcnts are initialized
> with 0 and charged only with "link" nodes. Now they'll start with
> 1 like usual. Thanks to Patrick McHardy for an improving suggestion.


Looks good, thanks Jarek.


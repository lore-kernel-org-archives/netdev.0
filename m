From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH take2][NET_SCHED] cls_u32: refcounting fix for
	u32_delete()
Date: Fri, 11 Apr 2008 09:55:27 -0400
Message-ID: <1207922127.4419.85.camel@localhost>
References: <20080411124519.GA2701@ff.dom.local>
	 <47FF5FBF.6030802@trash.net> <20080411132304.GB2701@ff.dom.local>
	 <47FF662B.2040302@trash.net>  <20080411134818.GA3776@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:32791 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758143AbYDKNzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 09:55:33 -0400
Received: by wr-out-0506.google.com with SMTP id c48so550868wra.1
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 06:55:33 -0700 (PDT)
In-Reply-To: <20080411134818.GA3776@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-11-04 at 13:48 +0000, Jarek Poplawski wrote:
> On Fri, Apr 11, 2008 at 03:22:51PM +0200, Patrick McHardy wrote:
> ...
> > I'd suggest to behave similar to qdiscs when trying to
> > removing classes that are still referenced, return -EBUSY.
> 
> Of course you are right!
> 
> Jarek P.
> 
> -------------------> (take 2)
> 
> [NET_SCHED] cls_u32: refcounting fix for u32_delete()
> 
> Deleting of nonroot hnodes mostly doesn't work in u32_delete():
> refcnt == 1 is expected, but such hnodes' refcnts are initialized
> with 0 and charged only with "link" nodes. Now they'll start with
> 1 like usual. Thanks to Patrick McHardy for an improving suggestion.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Jamal Hadi Salim <hadi@cyberus.ca>

Thanks as always Jarek.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal


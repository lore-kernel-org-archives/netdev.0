From: jamal <hadi@cyberus.ca>
Subject: Re: FSCKED clock sources WAS(Re: [WIP][PATCHES] Network xmit
	batching
Date: Mon, 25 Jun 2007 12:58:01 -0400
Message-ID: <1182790681.5184.38.camel@localhost>
References: <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <20070619.152801.99185860.davem@davemloft.net>
	 <1182441257.5017.48.camel@localhost>  <20070621164538.GA29001@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Robert.Olsson@data.slu.se,
	krkumar2@in.ibm.com, gaagaan@gmail.com, netdev@vger.kernel.org,
	rick.jones2@hp.com, sri@us.ibm.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:14194 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbXFYQ6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 12:58:05 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1512528wxc
        for <netdev@vger.kernel.org>; Mon, 25 Jun 2007 09:58:04 -0700 (PDT)
In-Reply-To: <20070621164538.GA29001@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-21-06 at 20:45 +0400, Evgeniy Polyakov wrote:
> On Thu, Jun 21, 2007 at 11:54:17AM -0400, jamal (hadi@cyberus.ca) wrote:
> > Evgeniy, did you sync on the batching case with the git tree?
> 
> My tree contains following commits:
> 
> Latest mainline commit: fa490cfd15d7ce0900097cc4e60cfd7a76381138
> Latest batch commit: 9b8cc32088abfda8be7f394cfd5ee6ac694da39c

That looks right. There have been a few fixes since, but mostly cosmetic
and shouldnt affect the results.
Strange - so far your results contradict both mine on pktgen (since you
show poor performance sometimes) and what Krishna posted on netperf
(since you show improvement).

BTW, on pktgen and batching - dont use the clone parameter for 
anything > 1. I have not tested that code-path at all and it is highly
likely buggy.

Thanks a lot for taking the time Evgeniy.

cheers,
jamal


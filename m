From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Possible regression in HTB
Date: Thu, 9 Oct 2008 10:14:26 +0000
Message-ID: <20081009101425.GC4159@ff.dom.local>
References: <20081007220022.GA2664@ami.dom.local> <20081008002153.GL12021@verge.net.au> <48EBFF5E.1090902@trash.net> <48EC0190.7040804@trash.net> <48EC6286.1030202@cdi.cz> <20081008085325.GF4174@ff.dom.local> <48EC8FDD.5030507@cdi.cz> <20081009010957.GB6342@verge.net.au> <48EDA339.3040706@cdi.cz> <20081009095600.GB4159@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:47948 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756100AbYJIKOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 06:14:31 -0400
Received: by ug-out-1314.google.com with SMTP id k3so887876ugf.37
        for <netdev@vger.kernel.org>; Thu, 09 Oct 2008 03:14:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081009095600.GB4159@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2008 at 09:56:00AM +0000, Jarek Poplawski wrote:
...
> So, maybe it would be interesting to try this other way:
> lower priority of the first class with a prio param e.g. 1?

Actually, this alone could be not enough, and lowering the quantum for
this class (e.g. quantum 10000) additionally could be useful.

Jarek P.

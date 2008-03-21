From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: possible lockdep crash
Date: Fri, 21 Mar 2008 17:23:30 +0200
Message-ID: <20080321152045.M11363@visp.net.lb>
References: <20080321093052.M39677@visp.net.lb> <20080321.033530.249188954.davem@davemloft.net> <20080321105404.M46676@visp.net.lb> <20080321.040408.153242166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:46455 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbYCUPXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 11:23:46 -0400
In-Reply-To: <20080321.040408.153242166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have very strange lockups on this machine, and i tried to catch them. But 
seems it doesn't help me, till now lockdep catch only ifb false-positive.

I will try to compile and run now without lockdep.

On Fri, 21 Mar 2008 04:04:08 -0700 (PDT), David Miller wrote
> From: "Denys Fedoryshchenko" <denys@visp.net.lb>
> Date: Fri, 21 Mar 2008 12:54:50 +0200
> 
> > Let me know if i can improve output to help debugging.
> > If possible it must be minimal risk to hang, cause router is in very 
> > difficult to reach area.
> 
> Can you disable lockdep and see if the problem persists?
> 
> It's killing your routing performance anyways, I have no
> idea why you have it enabled.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.


From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 4/4] rps: Inspect GRE encapsulated packets to get flow hash
Date: Thu, 19 May 2011 13:06:08 -0700
Message-ID: <BANLkTi=Q3N+_OEp4sLJu7wz5OW6gOCkciA@mail.gmail.com>
References: <alpine.DEB.2.00.1105190827420.12804@pokey.mtv.corp.google.com>
	<1305821795.3028.82.camel@edumazet-laptop>
	<20110519.153916.2250094502232694032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:27008 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933670Ab1ESUGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 16:06:12 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p4JK6AkV005021
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:06:10 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by kpbe18.cbf.corp.google.com with ESMTP id p4JK5XVb012628
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:06:09 -0700
Received: by pxi9 with SMTP id 9so2099447pxi.0
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 13:06:08 -0700 (PDT)
In-Reply-To: <20110519.153916.2250094502232694032.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Unless you look inside of the tunnel, you may not have any entropy
> at all for packet steering and that seems to be what Tom is trying
> to attack here.
>
Entropy for RPS, but flow identifier for RFS.  Also, this is not just
a SW problem, RSS doesn't seem to do anything creative with GRE
packets... I'm hoping we'll be able get support in NICs to do this
same functionality.

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC: 2.6 patch] the overdue removal of ip{,6}_queue
Date: Wed, 12 Apr 2006 20:14:13 +0200
Message-ID: <443D4375.2060105@trash.net>
References: <20060409180105.GK8454@stusta.de> <44395505.1070608@trash.net> <20060411090139.GI5167@rama.linbit> <443BC06A.8020103@trash.net> <20060411182624.GD31616@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, coreteam@netfilter.org,
	netdev@vger.kernel.org, sds@tycho.nsa.gov, jmorris@namei.org,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44470 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932306AbWDLSQw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Apr 2006 14:16:52 -0400
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20060411182624.GD31616@sunbeam.de.gnumonks.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Harald Welte wrote:
> On Tue, Apr 11, 2006 at 04:42:50PM +0200, Patrick McHardy wrote:
> 
>>I think we need to do two things:
>>
>>- make libipq_compat a drop-in replacement that doesn't require
>>  recompilation
> 
> 
> libipq is not distributed as a shared library (at least not by us), so I
> don't see any purpose for doing so.  Do you think anyone is going to
> re-link statically linked code against the new lib

I wasn't aware of that. That makes it even worse, old applications
will break and we can't do anything about it. I think this is
normally considered not acceptable.

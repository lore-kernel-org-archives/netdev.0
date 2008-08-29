From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Fri, 29 Aug 2008 07:57:37 -0500
Message-ID: <48B7F241.30201@linux-foundation.org>
References: <E1KYxzB-00021T-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38415 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750934AbYH2M7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 08:59:20 -0400
In-Reply-To: <E1KYxzB-00021T-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> What happened to Christoph Lameter's new per-cpu stuff? That would
> allows us to turn these into a single inc/add instruction.
> 
> So I think we should put this patch on the back-burner until the
> status of the per-cpu stuff is settled.

Well the zero based patchset is still not in for x86_64. The percpu stuff
would only work for x86_32. 32 bit uses the available segment register for per
cpu stuff. 64 bit wastes it on the pda.

Maybe its okay if itll just work for 32bit and it would put pressure on x86_64
to get the crap fixed up?


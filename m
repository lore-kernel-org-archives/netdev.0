From: Keir Fraser <keir@xensource.com>
Subject: Re: [Xen-devel] Re: [PATCH 3/4] [Net] Support Xen accelerated
 network plugin modules
Date: Tue, 22 May 2007 08:48:04 +0100
Message-ID: <C2785EC4.F4E3%keir@xensource.com>
References: <1179818921.4145.29.camel@moonstone.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <muli@il.ibm.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xensource.com>, <herbert@gondor.apana.org.au>
To: Kieran Mansley <kmansley@solarflare.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 207.47.60.4.static.nextweb.net ([207.47.60.4]:50491 "EHLO
	rpc.xensource.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755640AbXEVHsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 03:48:17 -0400
In-Reply-To: <1179818921.4145.29.camel@moonstone.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org




On 22/5/07 08:28, "Kieran Mansley" <kmansley@solarflare.com> wrote:

> On Tue, 2007-05-22 at 08:15 +0100, Kieran Mansley wrote:
>> RCU on its own wouldn't
>> prevent the accelerated plugin being unloaded while netfront was using
>> one of the hooks.
> 
> Hmm, actually I think it could be used to do that.  I'll take a look.

Eagerly zap the function pointers, then wait one RCU period so every CPU
goes through a quiescent point before unloading the module?

 -- Keir


From: David Miller <davem@davemloft.net>
Subject: Re: Some NIPQUAD_FMT -> %pI4 conversions are broken
Date: Fri, 09 Jan 2009 22:15:54 -0800 (PST)
Message-ID: <20090109.221554.190779821.davem@davemloft.net>
References: <adaprivom8o.fsf@cisco.com>
	<1231567645.5714.19.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbZAJGPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 01:15:53 -0500
In-Reply-To: <1231567645.5714.19.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Fri, 09 Jan 2009 22:07:25 -0800

> My apologies indeed, the best choice I think is to add a temp var
> for now and I'll work with you to eliminate the byteswapping further
> up the callchain so a be32 gets passed down, but that might be too
> involved for 2.6.29.

Alternatively we could provide a %p* variant that took
cpu endian addresses.

I don't know how useful that would be, generally.

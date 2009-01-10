From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: Some NIPQUAD_FMT -> %pI4 conversions are broken
Date: Fri, 09 Jan 2009 22:24:20 -0800
Message-ID: <1231568660.5714.23.camel@brick>
References: <adaprivom8o.fsf@cisco.com> <1231567645.5714.19.camel@brick>
	 <20090109.221554.190779821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.170]:40249 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbZAJGYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2009 01:24:22 -0500
Received: by wf-out-1314.google.com with SMTP id 27so10235504wfd.4
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2009 22:24:21 -0800 (PST)
In-Reply-To: <20090109.221554.190779821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-01-09 at 22:15 -0800, David Miller wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> Date: Fri, 09 Jan 2009 22:07:25 -0800
> 
> > My apologies indeed, the best choice I think is to add a temp var
> > for now and I'll work with you to eliminate the byteswapping further
> > up the callchain so a be32 gets passed down, but that might be too
> > involved for 2.6.29.
> 
> Alternatively we could provide a %p* variant that took
> cpu endian addresses.
> 
> I don't know how useful that would be, generally.

I don't think we want that, it would be better to just start work on the
nes drivers to work directly on be32s throughout, and eject all of the
byteswapping throughout the driver.

Having such a %p helper for host-endian just encourages more drivers to
be written the same way.

Harvey


From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: Q: bad routing table cache entries
Date: Tue, 12 Jan 2016 09:47:25 -0500
Message-ID: <20160112144725.GA30240@oracle.com>
References: <5682665A.7090102@list.ru>
 <20151229152208.GA22423@oracle.com>
 <5695106D.8040909@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Stas Sergeev <stsp@list.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:47941 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934724AbcALOre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 09:47:34 -0500
Content-Disposition: inline
In-Reply-To: <5695106D.8040909@list.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/12/16 17:40), Stas Sergeev wrote:
> Updated testing results:
> After I disabled shared_media not only for "all", but
> also for _all_ interfaces individually, the problem seem to
> have stopped. So thanks for these hints.
> Now, as the media is actually really shared (same NIC/cable),
> I just wonder what's going on here.

I dont know the history of the shared_media tunable (or
the rationale behind the default) - I was just reading out the
code - perhaps someone on the list who has the history can share 
the motivation behind this tunable.

> And unfortunately we still don't know why these redirects are
> ever accepted...

I would guess that it is accepted because there is nothing
(no RFC chapter/verse) saying it should not. 

But the fact remains that the network is sub-optimally configured-
each packet that triggers the redirect is now amplified at the 
router - one copy gets forwarded, and one redirect gets sent back. 

--Sowmini

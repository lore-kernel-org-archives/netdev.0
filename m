From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Wed, 10 Jan 2007 14:42:52 +0100
Message-ID: <45A4ED5C.5020800@trash.net>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <1168421515.6746.14.camel@bzorp.balabit> <45A4DCD8.2080103@trash.net> <200701101427.32243.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Balazs Scheidler <bazsi@balabit.hu>, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	KOVACS Krisztian <hidden@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932545AbXAJNm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 08:42:57 -0500
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200701101427.32243.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ingo Oeser wrote:
> Patrick McHardy schrieb:
> 
>>We support bitwise use of the mark everywhere in current kernels, so
>>that shouldn't be a problem anymore.
> 
> 
> For firewall mark based policy routing to work, one must still disable 
> rp_filter, because this lookup doesn't take the mark into account[1].

If distributions wouldn't enable it by default there would be no need
to disable it again :)

> So this statement is not quite true, although I believe you are probably right 
> for this case.
> 
> BTW: This rp_filter=0 requirement isn't even officially documented 
> 	(e.g. in the LARTC).

The kernel defaults to rp_filter = 0.

> [1] But does take TOS into account for historic (???) reasons.

With TOS the assumption of symetry is a bit more realistic than
with fwmarks, but it will probably still not work properly if
you actually use routing by TOS value.

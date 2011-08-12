From: Ulrich Weber <ulrich.weber@sophos.com>
Subject: Re: bridge: accept bridge own MAC address as local
Date: Fri, 12 Aug 2011 18:36:54 +0200
Message-ID: <4E4556A6.5050201@sophos.com>
References: <20110812113024.GA8900@babylon> <20110812091909.712fa36e@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-85.dex002.intermedia.net ([64.78.20.223]:45367 "EHLO
	dhost002-85.dex002.intermedia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751180Ab1HLQmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 12:42:31 -0400
In-Reply-To: <20110812091909.712fa36e@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2011 06:19 PM, Stephen Hemminger wrote:
> A cleaner way to do this would be better to put a local entry
> in the forwarding database when mac address is manually set.
> Then there would not be special case code.

I agree, would be nicer to have it in the forwarding db.

However to which bridge port should i attach this entry?
Seems to be wrong for me to have it attached to a not
related port...

The intention of this patch is to set the bridge MAC to any
address, not related to an bridge port interface.

Cheers
 Ulrich

--=20
Ulrich Weber | ulrich.weber@sophos.com | Senior Software Engineer
Astaro - a Sophos company | Amalienbadstr 41 | 76227 Karlsruhe | German=
y
Phone +49-721-25516-0 | Fax =96200 | www.astaro.com

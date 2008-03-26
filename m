From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][ICMP]: Dst entry leak in icmp_send host re-lookup code
 (v2).
Date: Wed, 26 Mar 2008 02:27:33 -0700 (PDT)
Message-ID: <20080326.022733.159053599.davem@davemloft.net>
References: <47EA1694.1080208@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, den@openvz.org,
	netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752286AbYCZJ1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 05:27:33 -0400
In-Reply-To: <47EA1694.1080208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 26 Mar 2008 12:25:40 +0300

> Commit 8b7817f3a959ed99d7443afc12f78a7e1fcc2063 ([IPSEC]: Add ICMP host
> relookup support) introduced some dst leaks on error paths: the rt
> pointer can be forgotten to be put. Fix it bu going to a proper label.
> 
> Found after net namespace's lo refused to unregister :) Many thanks to 
> Den for valuable help during debugging.
> 
> Herbert pointed out, that xfrm_lookup() will put the rtable in case
> of error itself, so the first goto fix is redundant.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Looks good, applied, thanks!

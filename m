From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fix SO_ORIGINAL_DST information leak (CVE-2006-1343)
Date: Fri, 26 May 2006 16:36:18 +0200
Message-ID: <44771262.6070503@trash.net>
References: <1148644246.21881.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:16267 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750818AbWEZOgU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 10:36:20 -0400
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1148644246.21881.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcel Holtmann wrote:
> Hi,
> 
> the fix for CVE-2006-1343 (information leak) never made it upstream:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=114148078223594&w=2
> 
> So here it is again against the latest git repository and with the
> additional line in net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c.


Applied, thanks Marcel. I think I missed this one because I saw it
appear in 2.4, so I concluded that Dave already applied it. Looking
at the Changelog it was Marcelo himself.


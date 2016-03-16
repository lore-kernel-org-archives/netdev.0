From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH ethtool 3/3] Documentation for IPv6 NFC
Date: Wed, 16 Mar 2016 14:54:07 +0000
Message-ID: <56E9738F.3080204@solarflare.com>
References: <56C1E73A.5090603@solarflare.com>
 <56C1E7FA.6050601@solarflare.com> <1457887638.3331.33.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:53126 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966575AbcCPPBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:01:07 -0400
In-Reply-To: <1457887638.3331.33.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/03/16 16:47, Ben Hutchings wrote:
> Why is ip6 added in the middle of the IPv4 flow-types here...
> ...and here...
> ...but not here?
Good catch; I will make them all like the last one.
> Missing nexthdr?
On the contrary, it needed to be removed from all the other places - there
is no nexthdr input, only l4proto.

-Ed

From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Wed, 6 Feb 2013 14:07:39 +0100
Message-ID: <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se>
 <20130206121248.GC10290@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:62472 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab3BFNKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 08:10:34 -0500
Content-Disposition: inline
In-Reply-To: <20130206121248.GC10290@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2013 at 01:12:48PM +0100, Hannes Frederic Sowa wrote:
> Fixing the output path should be relatively straightforward, please test
> the following patch.

Tested OK.

> Looking at the input path, I think there is also no input protection
> for ff01::/16 addresses from the wire if you bind such an address.

Yes, this needs to be filtered on the input side aswell.

//E

From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NET_SCHED]: Add mask support to fwmark classifier
Date: Sat, 26 Aug 2006 13:15:03 +0200
Message-ID: <44F02D37.3060605@trash.net>
References: <44EED0FC.4050108@trash.net>	 <20060825105428.GR3470@postel.suug.ch>  <44EEE6DE.4090703@trash.net> <1156517754.5162.170.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:6273 "EHLO stinky.trash.net")
	by vger.kernel.org with ESMTP id S964938AbWHZLR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Aug 2006 07:17:26 -0400
To: hadi@cyberus.ca
In-Reply-To: <1156517754.5162.170.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> Another approach could have been to add the mask as part of the hashing.
> and you add the new hash field not in the head rather in the filter. At
> runtime, you hash - walk the bucket and compare the mask as well as the
> index.

That doesn't work. To what do you compare it? We have a mark from the
packet .. but no mask. And we don't want to compare the mask but use
it to mask the mark value.


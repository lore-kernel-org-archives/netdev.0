From: Michal Soltys <soltys@ziu.info>
Subject: Re: Bridging broken/unfriendly
Date: Wed, 28 Sep 2011 17:21:31 +0200
Message-ID: <4E833B7B.50409@ziu.info>
References: <4E7E5976.1070200@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:4381 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752965Ab1I1PVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 11:21:32 -0400
In-Reply-To: <4E7E5976.1070200@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-09-25 00:28, Stephen Clark wrote:
> Hi,
>
> Is there some reason Linux bridging won't let the ip address be on
> one of the interfaces, like FreeBSD does, instead of the bridge device?
>

You can do that, though you have to remember about proper routing, and 
you will need ebtables to make some of the traffic not go through the 
bridge.

Check http://ebtables.sourceforge.net/examples/basic.html#all for more 
details.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: honor ifindex in case we receive ll
 addresses in router advertisements
Date: Wed, 23 Dec 2015 22:05:32 -0500 (EST)
Message-ID: <20151223.220532.2168386302652446543.davem@davemloft.net>
References: <1450907077-19424-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mh+netdev@zugschlus.de
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753647AbbLXDFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:05:34 -0500
In-Reply-To: <1450907077-19424-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 23 Dec 2015 22:44:37 +0100

> Marc Haber reported we don't honor interface indexes when we receive link
> local router addresses in router advertisements. Luckily the non-strict
> version of ipv6_chk_addr already does the correct job here, so we can
> simply use it to lighten the checks and use those addresses by default
> without any configuration change.
> 
> Link: <http://permalink.gmane.org/gmane.linux.network/391348>
> Reported-by: Marc Haber <mh+netdev@zugschlus.de>
> Cc: Marc Haber <mh+netdev@zugschlus.de>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks Hannes.

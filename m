From: Steven Barth <cyrus@openwrt.org>
Subject: Re: [PATCH v2] ipv6: fix inconsistent prefix route handling
Date: Mon, 17 Feb 2014 07:41:42 +0100
Message-ID: <5301AF26.7080102@openwrt.org>
References: <20140216165128.GF8634@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from chi.subsignal.org ([188.40.166.11]:40804 "EHLO
	chi.subsignal.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaBQGlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 01:41:44 -0500
In-Reply-To: <20140216165128.GF8634@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> This could too easily clean up valid on-link information if the address
> just happens to be in the same subnet. Would (ifp-flags &
> (IFA_F_PERMANENET|IFA_F_TEMPORARY) && !(...)) solve the problem, too?

No, that doesn't do the trick unfortunately. Seems that the 
(non-permanent) address created by "ip" don't have IFA_F_TEMPORARY set.
Any other good ideas?


Cheers,

Steven

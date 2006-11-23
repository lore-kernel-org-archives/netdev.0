From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac roaming behaviour
Date: Thu, 23 Nov 2006 13:48:51 +0100
Message-ID: <1164286131.14205.1.camel@ux156>
References: <Pine.LNX.4.63.0611231128570.1891@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:15802 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1757360AbWKWMsx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 07:48:53 -0500
To: Guennadi Liakhovetski <gl@dsa-ac.de>
In-Reply-To: <Pine.LNX.4.63.0611231128570.1891@pcgl.dsa-ac.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-23 at 13:27 +0100, Guennadi Liakhovetski wrote:

> Are these problems still present in the current kernels

yes.

> and if so, how can they be fixed?

by adding code to do all that to softmac. Note that that isn't such a
great idea because softmac is destined to reach end-of-life soon.

I suggest you investigate using d80211 (some people started zd1211rw
ports to it but I don't know if any works) and use wpa_supplicant for
the roaming.

johannes

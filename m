From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] improve netem reorder flexibility
Date: Fri, 18 Dec 2009 09:32:40 -0800
Message-ID: <20091218093240.64ca7d88@nehalam>
References: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Christian Samsel <christian.samsel@rwth-aachen.de>
To: Christian Samsel <christian.samsel@rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34586 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754951AbZLRRc4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 12:32:56 -0500
In-Reply-To: <1261142318-26249-1-git-send-email-christian.samsel@rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Dec 2009 14:18:37 +0100
Christian Samsel <christian.samsel@rwth-aachen.de> wrote:

> This patch adds a new feature to netem: The newly introduced parameter 
> reorderdelay TIME is the time a reordered packet is delayed. It can be used in
> a combination with delay TIME to enable netem to produce late packets, which is
> not possible in the standard netem / iproute2. In the standard version 
> reordered packets are always sent immediately and therefore are always early packets.

I like the idea but is it binary compatible with older kernels/ older iproute2
utilities?



-- 

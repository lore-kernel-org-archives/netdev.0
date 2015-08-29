From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: retain parsed IPv6 header fields in
 flow on error skipping extension headers
Date: Sat, 29 Aug 2015 13:40:19 -0700 (PDT)
Message-ID: <20150829.134019.1423323256685869514.davem@davemloft.net>
References: <1440806541-22729-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org, dev@openvswitch.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34690 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310AbbH2UkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2015 16:40:22 -0400
In-Reply-To: <1440806541-22729-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Sat, 29 Aug 2015 09:02:21 +0900

> When an error occurs skipping IPv6 extension headers retain the already
> parsed IP protocol and IPv6 addresses in the flow. Also assume that the
> packet is not a fragment in the absence of information to the contrary;
> that is always use the frag_off value set by ipv6_skip_exthdr().
> 
> This allows matching on the IP protocol and IPv6 addresses of packets
> with malformed extension headers.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied to net-next, thanks Simon.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] VRF-lite - v6
Date: Thu, 13 Aug 2015 22:45:21 -0700 (PDT)
Message-ID: <20150813.224521.867973376420345543.davem@davemloft.net>
References: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, hannes@stressinduktion.org,
	nicolas.dichtel@6wind.com, stephen@networkplumber.org,
	hadi@mojatatu.com, ebiederm@xmission.com, svaidya@brocade.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332AbbHNFpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 01:45:23 -0400
In-Reply-To: <1439499551-90231-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 13 Aug 2015 14:58:59 -0600

> In the context of internet scale routing a requirement that always comes
> up is the need to partition the available routing tables into disjoint
> routing planes. A specific use case is the multi-tenancy problem where
> each tenant has their own unique routing tables and in the very least
> need different default gateways.
> 
> This patch allows the ability to create virtual router domains (aka VRFs
> (VRF-lite to be specific) in the linux packet forwarding stack. The main
> observation is that through the use of rules and socket binding to interfaces,
> all the facilities that we need are already present in the infrastructure. What
> is missing is a handle that identifies a routing domain and can be used to
> gather applicable rules/tables and uniqify neighbor selection. The scheme used
> needs to preserves the notions of ECMP, and general routing principles.

Series applied, however...

I don't think the ipv6 dependency should be there until you actually add
ipv6 support to VRF-Lite.

Furthermore, when you do, you need to make it so that people can enable
VRF even if they don't turn ipv6 on.

Thanks.

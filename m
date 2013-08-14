From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] ipv6: make unsolicited report intervals
 configurable for mld
Date: Tue, 13 Aug 2013 17:09:51 -0700 (PDT)
Message-ID: <20130813.170951.2251390672805363491.davem@davemloft.net>
References: <20130813230346.GA16264@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	william.manley@youview.com, bcrl@kvack.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45703 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757974Ab3HNAJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 20:09:53 -0400
In-Reply-To: <20130813230346.GA16264@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 14 Aug 2013 01:03:46 +0200

> Commit cab70040dfd95ee32144f02fade64f0cb94f31a0 ("net: igmp:
> Reduce Unsolicited report interval to 1s when using IGMPv3") and
> 2690048c01f32bf45d1c1e1ab3079bc10ad2aea7 ("net: igmp: Allow user-space
> configuration of igmp unsolicited report interval") by William Manley made
> igmp unsolicited report intervals configurable per interface and corrected
> the interval of unsolicited igmpv3 report messages resendings to 1s.
> 
> Same needs to be done for IPv6:
> 
> MLDv1 (RFC2710 7.10.): 10 seconds
> MLDv2 (RFC3810 9.11.): 1 second
> 
> Both intervals are configurable via new procfs knobs
> mldv1_unsolicited_report_interval and mldv2_unsolicited_report_interval.
> 
> (also added .force_mld_version to ipv6_devconf_dflt to bring structs in
> line without semantic changes)
> 
> v2:
> a) Joined documentation update for IPv4 and IPv6 MLD/IGMP
>    unsolicited_report_interval procfs knobs.
> b) incorporate stylistic feedback from William Manley
> 
> v3:
> a) add new DEVCONF_* values to the end of the enum (thanks to David
>    Miller)
> 
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: William Manley <william.manley@youview.com>
> Cc: Benjamin LaHaise <bcrl@kvack.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.

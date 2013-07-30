From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/2] net: igmp: Allow user-space configuration of
 igmp unsolicited report interval
Date: Tue, 30 Jul 2013 16:55:57 -0700 (PDT)
Message-ID: <20130730.165557.1185057462473078021.davem@davemloft.net>
References: <1375107711-9029-1-git-send-email-william.manley@youview.com>
	<1375107711-9029-2-git-send-email-william.manley@youview.com>
	<20130730061426.GF2490@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: william.manley@youview.com, netdev@vger.kernel.org, bcrl@kvack.org,
	luky-37@hotmail.com, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837Ab3G3Xz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:55:58 -0400
In-Reply-To: <20130730061426.GF2490@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 30 Jul 2013 08:14:26 +0200

> On Mon, Jul 29, 2013 at 03:21:51PM +0100, William Manley wrote:
>> @@ -2099,6 +2103,10 @@ static struct devinet_sysctl_table {
>>  		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
>>  		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
>>  					      "force_igmp_version"),
>> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV2_UNSOLICITED_REPORT_INTERVAL,
>> +					      "igmpv2_unsolicited_report_interval"),
>> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
>> +					      "igmpv3_unsolicited_report_interval"),
>>  		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
>>  					      "promote_secondaries"),
>>  		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,
> 
> Why did you use DEVINET_SYSCTL_FLUSHING_ENTRY here? Wouldn't
> DEVINET_SYSCTL_RW_ENTRY be a better choice?

Agreed, there is no reason to flush the routing cache just because
the igmp unsolicited report interval changed.

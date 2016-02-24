From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/2] GENEVE/VXLAN: Enable outer Tx checksum by
 default
Date: Wed, 24 Feb 2016 10:41:30 -0500 (EST)
Message-ID: <20160224.104130.944927463190990372.davem@davemloft.net>
References: <CAEh+42iCxKb+OsMqR51nvzeCr_7n3WLncCaWNuctW7FbYijmCQ@mail.gmail.com>
	<20160223.132458.488971277682238141.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D41109A1B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, tom@herbertland.com, ecree@solarflare.com,
	aduyck@mirantis.com, netdev@vger.kernel.org,
	alexander.duyck@gmail.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285AbcBXPlf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 10:41:35 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D41109A1B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 24 Feb 2016 09:58:03 +0000

> From: David Miller
>> Sent: 23 February 2016 18:25
>> 
>> From: Jesse Gross <jesse@kernel.org>
>> Date: Tue, 23 Feb 2016 09:31:09 -0800
>> 
>> > Most OSs (including Linux with connected TCP sockets) use non-zero IP
>> > IDs so requiring this would effectively disable GRO.
>> 
>> +1
>> 
>> Any OS that wants to work with SLHC, as I mentioned, has to emit
>> monotonically increasing IP ID values in all packets, even those with
>> DF set.
> 
> Doesn't that leak a lot of info about the sending system?
> ISTR one OS deliberately randomising the IP ID values in order
> to avoid giving out information about the number of packets being sent.

The ID generater is per-flow, therefore I don't think this is an
issue.

And if it is an issue, then it exists for fragmented traffic on
every machine on the planet.

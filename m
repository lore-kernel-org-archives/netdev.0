From: David Miller <davem@davemloft.net>
Subject: Re: [pve-devel] bridge vlan range, kernel 4.1 : "message
 truncated" warning when too much vlans defined
Date: Thu, 10 Sep 2015 15:58:30 -0700 (PDT)
Message-ID: <20150910.155830.1391952981935838143.davem@davemloft.net>
References: <999679133.23642075.1438234304221.JavaMail.zimbra@oxygem.tv>
	<972878625.39892449.1441867226052.JavaMail.zimbra@oxygem.tv>
	<55F20396.9090505@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aderumier@odiso.com, ronen.arad@intel.com, netdev@vger.kernel.org,
	rami.rosen@intel.com
To: roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbbIJW6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 18:58:31 -0400
In-Reply-To: <55F20396.9090505@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roopa <roopa@cumulusnetworks.com>
Date: Thu, 10 Sep 2015 15:26:30 -0700

> On 9/9/15, 11:40 PM, Alexandre DERUMIER wrote:
>> Hi,
>>
>> This still not fixed in iproute 4.2.
>>
>> Is they any plan to increase the rtnl_dump_filter buffer size soon ?
>
> Instead of increasing the default size, it would be nicer if this was
> configurable for iproute2 (I haven't looked yet).

I would definitely prefer this be done in a run-time manner of some
sort, and then other libraries can use iproute2's logic as a reference
for how to deal with this reliably, properly, and in a %100
future-proof manner.

Something of the "if request X fails, double the buffer size" variety.

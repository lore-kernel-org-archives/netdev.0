From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created
 with no group
Date: Mon, 31 Mar 2014 16:18:51 -0400 (EDT)
Message-ID: <20140331.161851.1545173206165352304.davem@davemloft.net>
References: <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
	<20140325.205324.1845346581147557473.davem@davemloft.net>
	<20140329082918.GA5720@zed>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: or.gerlitz@gmail.com, dlstevens@us.ibm.com, cwang@twopensource.com,
	netdev@vger.kernel.org
To: mike.rapoport@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaCaUSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 16:18:55 -0400
In-Reply-To: <20140329082918.GA5720@zed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Date: Sat, 29 Mar 2014 11:29:18 +0300

> Hi David,
> 
> On Tue, Mar 25, 2014 at 08:53:24PM -0400, David Miller wrote:
>> 
>> It turns out we are going to partially revert that commit and
>> iptunnel_pull_header() will start doing the skb_dst_drop() again.
>> 
>> See:
>> 
>> 	http://patchwork.ozlabs.org/patch/332956/
>> 
>> for details.
>> 
>> Will that fix this bug too?
> 
> I've found some more corner cases in the vxlan driver and the patch
> below fixes them and my custom configuration case as well.

Mike, please submit this formally for inclusion, in a fresh patch posting,
without any other unrelated context, thanks.

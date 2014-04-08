From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sctp: wake up all assocs if sndbuf policy is
 per socket
Date: Tue, 08 Apr 2014 13:19:03 -0400 (EDT)
Message-ID: <20140408.131903.479985343376816007.davem@davemloft.net>
References: <1396964037-13245-1-git-send-email-dborkman@redhat.com>
	<20140408.125032.810691136561418545.davem@davemloft.net>
	<53442E4A.2090004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, tgraf@suug.ch, nhorman@tuxdriver.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44180 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795AbaDHRTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:19:05 -0400
In-Reply-To: <53442E4A.2090004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevich@gmail.com>
Date: Tue, 08 Apr 2014 13:13:46 -0400

> On 04/08/2014 12:50 PM, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Tue,  8 Apr 2014 15:33:57 +0200
>> 
>>>  [ When net-next opens up again, we need to think how
>>>    we can ideally make a new list interface and simplify
>>>    both open-coded list traversals. ]
>> 
>> I don't think you need a new list interface.
>> 
>> Instead, just have a back pointer to the sctp_sk() from the asoc, then
>> you can do normal list traversals over the asocs.
> 
> We already have that, but doing so will give preference to first
> association and possibly starving the last one.
> 
> This starvation avoidance is the whole point of having a per-association
> accounting.

I see, thanks for explaining.

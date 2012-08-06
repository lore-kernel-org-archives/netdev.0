From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Mon, 06 Aug 2012 13:47:37 -0700 (PDT)
Message-ID: <20120806.134737.1358773847818872075.davem@davemloft.net>
References: <87mx27rig7.fsf@xmission.com>
	<50201928.2030802@gmail.com>
	<874noflrzd.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, jan.ariyasu@gmail.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jan.ariyasu@hp.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756604Ab2HFUri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:47:38 -0400
In-Reply-To: <874noflrzd.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 06 Aug 2012 12:50:46 -0700

> Vlad Yasevich <vyasevich@gmail.com> writes:
> 
> 
>> Hi Eric
>>
>> Associations are looked up by ports, but then verifyed by addresses.
>> Also, associations belong to sockets and simply validating the socket
>> namespace should be sufficient.
> 
> True.  Your set of patches isn't quite as likely to malfunction as it
> looked at first glance.  It requires address reuse which happens accross
> namespaces but not too frequently.
> 
> As for validating the socket namespace I agree that is the fix and my
> patchset winds up doing it.

FWIW I much prefer Eric's patch set, it was so significantly easier to
read and validate than Jan's.

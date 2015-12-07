From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [BUG] net: performance regression on ixgbe (Intel 82599EB
 10-Gigabit NIC)
Date: Mon, 7 Dec 2015 10:25:07 -0800
Message-ID: <5665CF03.3030606@hpe.com>
References: <20151203162627.GA8989@redhat.com> <566078AA.5040804@gmail.com>
 <20151207112837.GA14417@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jirka Hladky <jhladky@redhat.com>,
	Adam Okuliar <aokuliar@redhat.com>,
	Kamil Kolakowski <kkolakow@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: Otto Sabart <osabart@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g9t1613g.houston.hp.com ([15.240.0.71]:33907 "EHLO
	g9t1613g.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753835AbbLGSZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 13:25:09 -0500
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com [15.201.208.55])
	(using TLSv1.2 with cipher DHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by g9t1613g.houston.hp.com (Postfix) with ESMTPS id 1CF6C60643
	for <netdev@vger.kernel.org>; Mon,  7 Dec 2015 18:25:09 +0000 (UTC)
In-Reply-To: <20151207112837.GA14417@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2015 03:28 AM, Otto Sabart wrote:
>> Hi Ota,
>>
>> It looks like there were a few changes that went through that could be
>> causing the regression.  The most obvious one that jumps out at me is commit
>> 72bfd32d2f84 ("ixgbe: disable LRO by default").  As such one thing you might
>> try doing is turning on LRO support via ethtool -k to see if that is the
>> issue you are seeing.
>>
>
> Hi Alex,
> enabling LRO resolved the problem.

So you had the same NIC and CPUs and whatnot on both sides?

rick jones

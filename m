From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 0/15] netdevice: Convert directly reference of	netdev->priv
 to netdev_priv()
Date: Wed, 27 Aug 2008 08:39:19 +0800
Message-ID: <48B4A237.9080606@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com> <1219765607.16297.16.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61448 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752215AbYH0Alt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 20:41:49 -0400
In-Reply-To: <1219765607.16297.16.camel@lap75545.ornl.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Dillow said the following on 2008-8-26 23:46:
> On Tue, 2008-08-26 at 18:12 +0800, Wang Chen wrote:
>> Following patches will convert directly reference of netdev->priv to netdev_priv().
>>
>> - Patch 1/15 is the safe convert which I believe will not make "after converted " worse
>> than "before converted".
> 
> When breaking a big patch into multiple messages, please put a diffstat
> for that message above the patch -- and it'd be good to have one in the
> introduction message as well. This lets reviewers take a quick glance
> and see if code they maintain is affected, rather than having to search
> through each message to see what files it touches.
> 

Thanks Dave.
Actually, I goldbricked.
When I split patch-1/15, I didn't make new separated patches,
instead, I just copy them to separated mails, so I lost the
diffstat.

And I will be more diligent next time :)


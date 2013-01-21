From: Daniel Wagner <wagi@monom.org>
Subject: Re: [PATCH] net: net_cls: fd passed in SCM_RIGHTS datagram not set
 correctly
Date: Mon, 21 Jan 2013 11:16:50 +0100
Message-ID: <50FD1592.2000907@monom.org>
References: <1358761102-7765-1-git-send-email-wagi@monom.org> <50FD1058.2000306@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Li Zefan <lizefan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:43987 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033Ab3AUKQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 05:16:53 -0500
In-Reply-To: <50FD1058.2000306@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21.01.2013 10:54, Li Zefan wrote:
> On 2013/1/21 17:38, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner@bmw-carit.de>
>>
>> Commit 6a328d8c6f03501657ad580f6f98bf9a42583ff7 changed the update
>> logic for the socket but it does not update the SCM_RIGHTS update
>> as well. This patch is based on the net_prio fix commit
>>
>> 48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8
>>
>>      net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
>>
>>      A socket fd passed in a SCM_RIGHTS datagram was not getting
>>      updated with the new tasks cgrp prioidx. This leaves IO on
>>      the socket tagged with the old tasks priority.
>>
>>      To fix this add a check in the scm recvmsg path to update the
>>      sock cgrp prioidx with the new tasks value.
>>
>> Let's apply the same fix for net_cls.
>>
>> Reported-by: Li Zefan <lizefan@huawei.com>
> 
> Acutally I didn't report this. 

You made me look into this, so you reported it at least in my eyes :)

> I was about to send exactly the same
> patch and then I noticed the shared socket issue. ;)

I don't mind if you want your patch to be applied. I just felt
responsible for the changes I did.

thanks,
daniel

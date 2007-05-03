From: Pavel Emelianov <xemul@sw.ru>
Subject: Re: [PATCH] Rework dev_base via list_head (v2)
Date: Thu, 03 May 2007 18:44:18 +0400
Message-ID: <4639F542.7010800@sw.ru>
References: <4639C95A.3030809@sw.ru> <4639CB11.2050508@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Kirill Korotaev <dev@sw.ru>, devel@openvz.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:32510 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162051AbXECOoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2007 10:44:32 -0400
In-Reply-To: <4639CB11.2050508@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Pavel Emelianov wrote:
>> Cleanup of dev_base list use, with the aim to simplify making
>> device list per-namespace. In almost every occasion, use of
>> dev_base variable and dev->next pointer could be easily replaced
>> by  for_each_netdev loop. A few most complicated places were
>> converted to using first_netdev()/next_netdev().
>>
>> Changes:
>> * David's comment about loop termination;
>> * Applies to todays netdev git tree.
> 
> 
> This seems to be missing fs/afs/netdevices.c.
> 

Hm... I've cloned the git repo this morning but there's not such file...

$ ls fs/afs/netdevices.c
/bin/ls: fs/afs/netdevices.c: No such file or directory

Repo was cloned from
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git

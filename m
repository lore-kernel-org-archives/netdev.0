From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: net-2.6.25 being rebased...
Date: Tue, 11 Dec 2007 13:31:29 -0800
Message-ID: <475F01B1.2080400@intel.com>
References: <20071211.092638.148402625.davem@davemloft.net>	<20071211.115619.199600421.davem@davemloft.net>	<1197407100.4911.150.camel@localhost> <20071211.130858.134618588.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42729 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbXLKVdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Dec 2007 16:33:54 -0500
In-Reply-To: <20071211.130858.134618588.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 11 Dec 2007 13:04:59 -0800
> 
>> On Tue, 2007-12-11 at 11:56 -0800, David Miller wrote:
>>> The rebase of net-2.6.25 is complete
>> I have an earlier unmodified git repository of net-2.6.25.
>> Does anyone know the appropriate git commands to resync
>> to the rebased content?
>>
>> $ git branch
>> * master
>> $ git-pull
>> [...]
>> Automatic merge failed; fix conflicts and then commit the result.
> 
> Easiest thing to do is do a quick local clone of Linus's current tree
> (you do have one of these around right? :-) and then pull in from the
> rebased tree.
> 
> bash$ git clone linux-2.6/.git net-2.6.25
> bash$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git

I often have success without recloning by doing:

$ git-reset --hard v2.6.23
$ git pull git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.25.git

saves you the time to reclone. As long as you reset below the rebase point, this
should be OK.

Auke

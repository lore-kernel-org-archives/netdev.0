From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/5] cgroup cls & netprio 'cleanups'
Date: Fri, 13 Jul 2012 08:04:09 -0700 (PDT)
Message-ID: <20120713.080409.1140521272219611710.davem@davemloft.net>
References: <1341999341-1808-1-git-send-email-wagi@monom.org>
	<50002861.4070205@monom.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cgroups@vger.kernel.org, netdev@vger.kernel.org
To: wagi@monom.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41952 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546Ab2GMPEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 11:04:12 -0400
In-Reply-To: <50002861.4070205@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <wagi@monom.org>
Date: Fri, 13 Jul 2012 15:53:37 +0200

> On 11.07.2012 11:35, Daniel Wagner wrote:
>> The next two patches are changing the built. In case someone
>> builds a kernel with cgroup support but disabled cls or netprio
>> controller, there was still code added.
>>
>> And the last two patches change the cls and netprio source files in
>> that way, that the use IS_BUILTIN and IS_MODULE as it used in the
>> header files.
> 
> Forget patch #2 - #5.
> 
> I'll have a new version soon ready which changes the *_subsys_id part
> to always beeing a enum. This allows to remove the rather unpleasant
> module loading part with the ID assignment.

Resubmit the entire set once the new versions of #2 - #5 are ready.

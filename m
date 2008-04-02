From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 14:09:06 +0200
Message-ID: <47F37762.2030705@trash.net>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme>	 <47F13E43.2040404@trash.net>	 <20080331.130757.199769025.davem@davemloft.net>	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>	 <47F35933.5080305@trash.net>  <20080402112103.GB20815@postel.suug.ch> <1207137667.4451.143.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbYDBMJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:09:09 -0400
In-Reply-To: <1207137667.4451.143.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Wed, 2008-02-04 at 13:21 +0200, Thomas Graf wrote:
> 
>> Probably fixable though.
> 
> One way "i fixed it" was removed by Alexey in commit:
> 28633514afd68afa77ed2fa34fa53626837bf2d5
> 
> Note: Alexey is right of course.

Yes, but it was the use of current->pid that was wrong.
If one of those calls are in a path invoked through netlink
it should set nlmsg_pid.

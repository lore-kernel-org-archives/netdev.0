From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 14:03:33 +0200
Message-ID: <47F37615.1090502@trash.net>
References: <47EAAFEC.6000805@trash.net> <20080331123311.64e4ca37@extreme> <47F13E43.2040404@trash.net> <20080331.130757.199769025.davem@davemloft.net> <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost> <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost> <47F35933.5080305@trash.net> <20080402112103.GB20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63157 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753073AbYDBMDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 08:03:38 -0400
In-Reply-To: <20080402112103.GB20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> * Patrick McHardy <kaber@trash.net> 2008-04-02 12:00
>> jamal wrote:
>>> On Tue, 2008-01-04 at 13:52 +0200, Patrick McHardy wrote:
>>>
>>>> Isn't that what nlmsg_pid already contains?
>>> would work only on the case of user<->user.
>>> On kernel->user it is supposed to be owned by the kernel and set to 0.
>>
>> No, in the case of events its supposed to be set to the pid of the
>> socket that caused the event. Check out qdisc_notify() or rtmsg_ifa()
>> for example.
> 
> Unfortunately in many cases the pid is also set to 0 because the
> information is lost when carrying the event using the notifier
> interface. Probably fixable though.


Yes, I remember some cases but couldn't find them anymore.
Tt should be fixed IMO since there's not much value in this
if its used inconsistently.

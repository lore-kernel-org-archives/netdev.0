From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Fri, 08 Oct 2010 09:58:01 -0700
Message-ID: <m1k4ls1v1i.fsf@fess.ebiederm.org>
References: <201010071048.12817.hans.schillstrom@ericsson.com>
	<4CAEFE2C.3010007@free.fr>
	<201010081353.28056.hans.schillstrom@ericsson.com>
	<201010081428.37639.hans.schillstrom@ericsson.com>
	<4CAF3E78.8030202@free.fr> <4CAF4408.6070001@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Lezcano <daniel.lezcano@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:36846 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab0JHQ6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:58:07 -0400
In-Reply-To: <4CAF4408.6070001@free.fr> (Daniel Lezcano's message of "Fri, 08
	Oct 2010 18:17:12 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Lezcano <daniel.lezcano@free.fr> writes:

> On 10/08/2010 05:53 PM, Daniel Lezcano wrote:
>> On 10/08/2010 02:28 PM, Hans Schillstrom wrote:
>>> Hi Eric,
>>> Any advice how to trace this down ?
>>> This rollback_registered_many() seems to have on the lists before...
>>> All IPv4 and IPv6 tunnels causes this crash, all you have to do is
>>> load the tunnel module(s)
>>> enter a new ns and exit from it.
>>>
>>> Have not tested any more devices than tunnels,
>>> I did an "ip link delete" on my macvlans before exiting the ns.
>>
>> Ah ! I succeed to reproduce it.
>> It does not appear immediately in fact.
>>
>> I am trying to simplify the configuration but I am falling in the bug I
>> talked about in the previous email.
>
> Ok, so after investigating, we just need a macvlan and specify an ipv6 address
> for it (inside a new netns of course), and the loopback is not released. I
> compiled out the tunnels, so they are not related to this problem I think.
>
> That reduces the scope of investigation :)

This reproduces the unable to free nedevice problem?  Or the bad
pointer in macvlan_close problem?

Eric

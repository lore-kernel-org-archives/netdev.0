From: Ferenc Wagner <wferi@niif.hu>
Subject: Re: ipv6 debugging
Date: Mon, 18 Feb 2008 22:46:50 +0100
Message-ID: <87mypygcol.fsf@szonett.ki.iif.hu>
References: <87zltyjr50.fsf@tac.ki.iif.hu>
	<3740A925537C481CAA40DE393FA0D00E@intranet.dti2.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:49310 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751738AbYBRVqx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 16:46:53 -0500
In-Reply-To: <3740A925537C481CAA40DE393FA0D00E@intranet.dti2.net> (Jorge
	Boncompte's message of "Mon, 18 Feb 2008 16:02:05 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Jorge Boncompte [DTI2]" <jorge@dti2.net> writes:

> Ferenc Wagner <wferi@niif.hu> writes:
>
>> I'm kindly asking for some debugging tips with the following problem:
>> a machine is running Linux 2.6.24.2, several 802.1q VLAN-s over
>> active/backup bonding over two physical interfaces.  Everything is
>> allright, except for after a reboot, there's no IPv6, while IPv4
>> works.  The router's ARP(6) table is empty, the machine doesn't answer
>> ping6.  However, if I start tcpdump -i bond0 ip6, everything is
>> allright again.  There are some indications that after some period
>> without IPv6 traffic, the same can happen again.  Are there known
>> issues which can exhibit themselves like this?  Other very similar
>> setups don't show this erratic behaviour.
>>
>> I know that the above doesn't give a fully detailed picture, but
>> thought that I'd better ask before taking the setup into pieces.
>
> This sounds to me like the same problem that I was having with
> OSPF, I think ARP(6) uses multicast ethernet address too. Can you try
> if the patch below, that I sent Patrick McHardy some days ago, fixes
> your problem?

Hi Jorge,

Thank you very much!  Your patch indeed fixes my problem.  I hope the
fix will make it into a stable release soon!
-- 
Regards,
Feri.

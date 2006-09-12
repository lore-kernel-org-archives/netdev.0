From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC] network namespaces
Date: Mon, 11 Sep 2006 21:28:47 -0600
Message-ID: <m1zmd57ogg.fsf_-_@ebiederm.dsl.xmission.com>
References: <20060815182029.A1685@castle.nmd.msu.ru>
	<4505757B.3020004@fr.ibm.com>
	<20060911145724.GB27223@MAIL.13thfloor.at>
	<200609111910.31624.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Kir Kolyshkin <kir@openvz.org>, Andrey Savochkin <saw@sw.ru>,
	netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:32937 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S964855AbWILD3t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 23:29:49 -0400
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200609111910.31624.dim@openvz.org> (Dmitry Mishin's message of
	"Mon, 11 Sep 2006 19:10:31 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin <dim@openvz.org> writes:

> On Monday 11 September 2006 18:57, Herbert Poetzl wrote:
>> I completely agree here, we need a separate namespace
>> for that, so that we can combine isolation and virtualization
>> as needed, unless the bind restrictions can be completely
>> expressed with an additional mangle or filter table (as
>> was suggested)
>
> iptables are designed for packet flow decisions and filtering, it has nothing 
> common with bind restrictions. So, it may be only packet flow 
> scheduling/filtering, but it will not help to resolve bind-time IP conflicts.

Please read the archive, where the suggestion was made.

What was suggested was a new table, with it's own set of chains.
So we could make filtering decisions on where sockets could be bound.

That is not a far stretch from where iptables is today.

Do you have some concrete arguments against the proposal?

Eric

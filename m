From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6 v2] bonding: allow resetting slave failure
 counters
Date: Wed, 1 Jun 2011 22:27:49 +0200
Message-ID: <20110601202748.GE2784@psychotron.redhat.com>
References: <20110601163153.GB2784@psychotron.redhat.com>
 <4DE6919F.3030304@gmail.com>
 <20110601200854.GD2784@psychotron.redhat.com>
 <20110601.131243.2063791013719464193.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.2p.debian@gmail.com, fubar@us.ibm.com, fbl@redhat.com,
	netdev@vger.kernel.org, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24339 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752607Ab1FAU2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 16:28:01 -0400
Content-Disposition: inline
In-Reply-To: <20110601.131243.2063791013719464193.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2011 at 10:12:43PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Wed, 1 Jun 2011 22:08:55 +0200
>
>> Wed, Jun 01, 2011 at 09:23:11PM CEST, nicolas.2p.debian@gmail.com wr=
ote:
>>>Le 01/06/2011 18:31, Jiri Pirko a =E9crit :
>>>>This patch allows to reset failure counters for all enslaved device=
s.
>>>
>>>Hi Jiri,
>>>
>>>Why do we need a way to reset those counters? What is the problem
>>>with having those counters monotonically increase until the system i=
s
>>>rebooted? Do we have a way to reset other network statistics
>>>(/sys/class/net/eth0/statistics/* for example)?
>>=20
>> Well, it's handy to be able to clear this counters when you resolve
>> a problem so future issues are crearly seen as non-zero.				  =20
>
>We don't allow this in any way for netdev counters, for good reasons,
>so please don't add things like this.
>

Well technically this is not netdev counter directly. But fair enough.

Thanks.

Jirka

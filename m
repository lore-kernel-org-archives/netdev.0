From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH, RFC] bonding: prevent outgoing packets on inactive slaves
Date: Thu, 06 Aug 2009 14:28:39 +0200
Message-ID: <4A7ACC77.5050702@gmail.com>
References: <20090805162429.GD16093@midget.suse.cz> <4A79BA01.502@gmail.com> <20090806104356.GA8024@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35337 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbZHFM2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 08:28:50 -0400
In-Reply-To: <20090806104356.GA8024@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac a =E9crit :
> On Wed, Aug 05, 2009 at 06:57:37PM +0200, Eric Dumazet wrote:
>> Jiri Bohac a =E9crit :
>>> This patch makes sure the TX queues on inactive slaves are
>>> deactivated.
>>>
>> Wont this break ARP link monitoring ?
>=20
> No, ARP monitoring sends the ARP requests from the active slave.
>=20

Yes, this makes sense now you say it :)

Thanks

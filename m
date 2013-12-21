From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] sctp: fix missing include file
Date: Sat, 21 Dec 2013 10:44:30 +0100
Message-ID: <52B562FE.4000207@redhat.com>
References: <20131221025110.9758.12509.stgit@monster-03.cumulusnetworks.com> <20131221.000055.1377147691178558975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sfeldma@cumulusnetworks.com, vyasevich@gmail.com,
	nhorman@tuxdriver.com, netdev@vger.kernel.org,
	roopa@cumulusnetworks.com, shm@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22149 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528Ab3LUJor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Dec 2013 04:44:47 -0500
In-Reply-To: <20131221.000055.1377147691178558975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/2013 06:00 AM, David Miller wrote:
> From: Scott Feldman <sfeldma@cumulusnetworks.com>
> Date: Fri, 20 Dec 2013 18:51:10 -0800
>
>> Compile error reported by Jim Davis on netdev.
>>
>> ip6_sk_accept_pmtu() needs net/ip6_route.h
>>
>> Signed-off-by: Scott Feldman <sfeldma@cumulusnetworks.com>
>
> Applied, thanks.

Sorry for the late reply as I'm on travel with limited connectivity.

Scott, this fix is not correct, and probably should be reverted. The
correct one was already in patchwork under [1]. In SCTP, we have
net/sctp/ipv6.c for all IPv6 related functions. Also there, this
include file is already present.

Thanks !

  [1] http://patchwork.ozlabs.org/patch/303308/

From: Haggai Eran <haggaie@mellanox.com>
Subject: Re: [PATCH v4 for-next 00/12] Add network namespace support in the
 RDMA-CM
Date: Tue, 19 May 2015 17:54:54 +0300
Message-ID: <555B4EBE.7010900@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
 <1432045826.5304.6.camel@opteya.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Doug Ledford <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
	<netdev@vger.kernel.org>, Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>
To: Yann Droneaud <ydroneaud@opteya.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0072.outbound.protection.outlook.com ([157.56.112.72]:56288
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932612AbbESOzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 10:55:08 -0400
In-Reply-To: <1432045826.5304.6.camel@opteya.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/05/2015 17:30, Yann Droneaud wrote:
>Le dimanche 17 mai 2015 =C3=A0 08:50 +0300, Haggai Eran a =C3=A9crit :
>> Full support for RoCE will be introduced in a later stage.
>>
> How does this play with iWarp: as iWarp HCA are aware of IP addresses=
 /
> UDP/TCP ports, AFAIK, are those tied to namespace with this patchset =
or
> will it be possible to use the iWarp HCA to access to address/port
> resources tied to a different namespace ?

At the moment the patchset doesn't add iWarp namespace support, as I
wrote in the discussion about v3 [1]. I suspect that the current iWarp
code lets users listen in one namespace and receive requests belonging
to the init namespace, or break the namespaces in similar ways. The
patchset doesn't attempt to fix this for iWarp or RoCE, only for Infini=
Band.

Regards,
Haggai

[1] http://www.spinics.net/lists/linux-rdma/msg25156.html

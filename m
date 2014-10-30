From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6
 pseudo header checksum
Date: Thu, 30 Oct 2014 18:32:43 +0200
Message-ID: <5452682B.2030802@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com> <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com> <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog131.obsmtp.com ([207.126.144.205]:53317 "EHLO
	eu1sys200aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760507AbaJ3Qdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:33:38 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2014 6:25 PM, David Laight wrote:
>> >+static inline __wsum csum_ipv6_magic_nofold(const struct in6_addr *saddr,
>> >+					    const struct in6_addr *daddr,
>> >+					    __u32 len, unsigned short proto,
>> >+					    __wsum sum)
>> >+{
>> >+	__wsum res = sum;
>> >+
>> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[0]);
>> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[1]);
>> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[2]);
>> >+	res = csum_add(res, (__force __wsum)saddr->in6_u.u6_addr32[3]);
>> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[0]);
>> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[1]);
>> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[2]);
>> >+	res = csum_add(res, (__force __wsum)daddr->in6_u.u6_addr32[3]);
> That probably generates a very long dependency chain.
>

Could you clarify this comment a bit?

Or.

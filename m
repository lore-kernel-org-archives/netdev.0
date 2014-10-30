From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 7/8] net: Add calaulation of non folded IPV6
 pseudo header checksum
Date: Thu, 30 Oct 2014 18:55:35 +0200
Message-ID: <54526D87.7090107@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com> <1414685216-28907-8-git-send-email-ogerlitz@mellanox.com> <063D6719AE5E284EB5DD2968C1650D6D1C9E2415@AcuExch.aculab.com> <5452682B.2030802@mellanox.com> <063D6719AE5E284EB5DD2968C1650D6D1C9E2497@AcuExch.aculab.com> <54526D3C.2040604@mellanox.com>
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
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:55040 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758190AbaJ3Qzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:55:53 -0400
In-Reply-To: <54526D3C.2040604@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 10/30/2014 6:54 PM, Or Gerlitz wrote:
> sum = csum_partial(saddr, sizeof(daddr->in6_u.u6_addr32), sum); 
s/saddr/daddr/ sorry for the spam

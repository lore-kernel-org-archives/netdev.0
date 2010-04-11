From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tcp: Handle CHECKSUM_PARTIAL for SYNACK packets
 for IPv4
Date: Sun, 11 Apr 2010 15:00:04 -0700 (PDT)
Message-ID: <20100411.150004.104064842.davem@davemloft.net>
References: <20100411100902.GA20141@gondor.apana.org.au>
	<E1O0w4v-0005UZ-GF@gondolin.me.apana.org.au>
	<4BC23A1C.9020607@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, torvalds@linux-foundation.org
To: yinghai.lu@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4BC23A1C.9020607@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yinghai <yinghai.lu@oracle.com>
Date: Sun, 11 Apr 2010 14:07:40 -0700

> On 04/11/2010 05:15 AM, Herbert Xu wrote:
>> tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for IPv4
>> 
>> This patch moves the common code between tcp_v4_send_check and
>> tcp_v4_gso_send_check into a new function __tcp_v4_send_check.
>> 
>> It then uses the new function in tcp_v4_send_synack so that it
>> handles CHECKSUM_PARTIAL properly.
>> 
> Good, three patches fix the problem.

Thanks for testing.

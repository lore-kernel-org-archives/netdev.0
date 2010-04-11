From: Yinghai <yinghai.lu@oracle.com>
Subject: Re: [PATCH 1/3] tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for
 IPv4
Date: Sun, 11 Apr 2010 14:07:40 -0700
Message-ID: <4BC23A1C.9020607@oracle.com>
References: <20100411100902.GA20141@gondor.apana.org.au> <E1O0w4v-0005UZ-GF@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org
To: Herbert Xu <herbert@gondor.hengli.com.au>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E1O0w4v-0005UZ-GF@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2010 05:15 AM, Herbert Xu wrote:
> tcp: Handle CHECKSUM_PARTIAL for SYNACK packets for IPv4
> 
> This patch moves the common code between tcp_v4_send_check and
> tcp_v4_gso_send_check into a new function __tcp_v4_send_check.
> 
> It then uses the new function in tcp_v4_send_synack so that it
> handles CHECKSUM_PARTIAL properly.
> 
Good, three patches fix the problem.

Thanks

Yinghai

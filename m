From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Sun, 04 Dec 2005 23:09:09 +0100
Message-ID: <43936905.2000700@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
	<20051122044046.GA29166@gondor.apana.org.au>
	<4382A44F.9000105@trash.net>
	<20051122103038.GA31532@gondor.apana.org.au>
	<20051122103139.GA4632@gondor.apana.org.au>
	<20051122121358.GA9057@gondor.apana.org.au>
	<438A5837.5040706@trash.net>
	<20051128045611.GA9571@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20051128045611.GA9571@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
>>before tunnel mode transforms and added a missing dst_output call
>>for the final packet.
> 
> This shouldn't be necessary if you apply it on top of my previous
> patch which made xfrm[46]_output process the first SA and all subsequent
> transport mode SAs.  I've included that patch here again.

Thanks, I've added the correct patch now :) Unless I missed something,
it was still missing a call to dst_output after the last transform
in xfrm4_output_finish, unless we keep the loop in dst_output.

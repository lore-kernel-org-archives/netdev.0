From: Patrick McHardy <kaber@trash.net>
Subject: Re: [netfilter-core] [NETFILTER] Apply IPsec to ipt_REJECT packets
Date: Tue, 23 Nov 2004 22:44:33 +0100
Message-ID: <41A3AF41.4010700@trash.net>
References: <20041123084225.GA3514@gondor.apana.org.au> <41A37EC0.8010901@trash.net> <20041123211630.GA9805@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, coreteam@netfilter.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041123211630.GA9805@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Tue, Nov 23, 2004 at 07:17:36PM +0100, Patrick McHardy wrote:
>  
>
>>The patch doesn't handle tcp resets sent in response to a forwarded packet.
>>I'll send a patch later tonight.
>>    
>>
>
>Isn't that handled by ip_forward itself?
>  
>
No. ip_forward handles the original packet, not the packet generated
by ipt_REJECT. RSTs generated in NF_IP_FORWARD are routed using
ip_route_input because they have a non-local source, so xfrm_route_forward
or xfrm_lookup needs to be called for them.

Regards
Patrick

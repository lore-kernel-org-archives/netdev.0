From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: PATCH: IPSEC xfrm events
Date: Sat, 02 Apr 2005 02:28:07 +0900
Message-ID: <424D84A7.6060707@linux-ipv6.org>
References: <1112319441.1089.83.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1112319441.1089.83.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jamal and Herbert,

jamal wrote:
> Herbert et al,
> 
> Ok, heres the final patch with all the changes discussed.
> 
>  include/linux/xfrm.h   |    2 
>  include/net/xfrm.h     |   29 ++++++-
>  net/key/af_key.c       |   24 +++++-
>  net/xfrm/xfrm_policy.c |   25 ++++--
>  net/xfrm/xfrm_state.c  |   84 +++++++++++++++++++--
>  net/xfrm/xfrm_user.c   |  188
> ++++++++++++++++++++++++++++++++++++++++++++++++-
>  6 files changed, 323 insertions(+), 29 deletions(-)
> 
> I have tested this with both setkey and iproute2 (about 10 scenarios or
> so). Masahide-san is doing a lot more thorough testing with key servers
> as well. He has not tested this patch yet (time difference) but it is
> based on the last one he tested.

Short report:
I've tested on this patched kernel and it works.

- add/del/flush for SA/SP and  allocspi/acquire/upd for SA
  through netlink socket
- racoon runs fine (pfkey works for normal operation)
  both without and with opening netlink socket to listen

Since we have discussion which is still going on about the patch,
the code will be change and I'll need to test again anyway.

Thanks,

-- 
Masahide NAKAMURA

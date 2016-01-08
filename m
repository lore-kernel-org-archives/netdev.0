From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 15:33:23 +0000
Message-ID: <568FD6C3.9090402@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
 <568E9C9B.3090408@solarflare.com>
 <CAKgT0UePUo+qN+gv3R_4Uge=q=GUd4-39BxgecXmYCXLohLt2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:2604 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754705AbcAHPde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 10:33:34 -0500
In-Reply-To: <CAKgT0UePUo+qN+gv3R_4Uge=q=GUd4-39BxgecXmYCXLohLt2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/16 00:15, Alexander Duyck wrote:
> On Thu, Jan 7, 2016 at 9:12 AM, Edward Cree <ecree@solarflare.com> wrote:
>> Signed-off-by: Edward Cree <ecree@solarflare.com>
>> ---
>>  drivers/net/vxlan.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
>> index 6369a57..d4acbc9 100644
>> --- a/drivers/net/vxlan.c
>> +++ b/drivers/net/vxlan.c
>> @@ -1733,7 +1733,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
>>                 goto err;
>>         }
>>
> A few lines up from here there is a "udp_sum = false" that can be
> dropped for the remote checksum stuff.
Good catch.  Fixed up these (and equivalents in the FOU/GUE patch) for the
 nextversion of the patch series.

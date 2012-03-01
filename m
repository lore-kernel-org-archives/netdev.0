From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 3/3] netfilter: Remove redundant code.
Date: Thu, 1 Mar 2012 15:54:58 +0530
Message-ID: <CAOD=uF6T-POkOORw6_S7_NtHgLX4GJj_9A8tg4QRCc8=gCvFaA@mail.gmail.com>
References: <1330593466-19317-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120301102341.GC6488@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bart.de.schuymer@pandora.be, kaber@trash.net,
	shemminger@vyatta.com, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120301102341.GC6488@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please see last line of my 2nd patch.
I have added a new label "out" .


regards
santosh

On Thu, Mar 1, 2012 at 3:53 PM, Pablo Neira Ayuso <pablo@netfilter.org>=
 wrote:
> On Thu, Mar 01, 2012 at 02:47:46PM +0530, santosh nayak wrote:
>> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>>
>> Remove the redundant code.
>>
>> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
>> ---
>> =A0net/bridge/netfilter/ebtables.c | =A0 18 ++++++------------
>> =A01 files changed, 6 insertions(+), 12 deletions(-)
>>
>> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/=
ebtables.c
>> index 9c0f177..1efc234 100644
>> --- a/net/bridge/netfilter/ebtables.c
>> +++ b/net/bridge/netfilter/ebtables.c
>> @@ -226,10 +226,8 @@ unsigned int ebt_do_table (unsigned int hook, s=
truct sk_buff *skb,
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (EBT_MATCH_ITERATE(point, ebt_do_matc=
h, skb, &acpar) !=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto letscontinue;
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (acpar.hotdrop) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 read_unlock_bh(&table->loc=
k);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NF_DROP;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (acpar.hotdrop)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>
> This is really broken! there's no "out" label in ebt_do_table as in
> the previous patch!
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

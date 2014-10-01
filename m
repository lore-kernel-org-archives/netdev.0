From: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Subject: Re: [PATCH 33/34] netfilter: nf_tables: store and dump set policy
Date: Wed, 1 Oct 2014 15:47:16 +0200
Message-ID: <CAOkSjBi59RdovSXCPMYHF8crscKFYOmK9i8Fpt2kLGvOJfT_gA@mail.gmail.com>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
 <1411994363-8451-34-git-send-email-pablo@netfilter.org> <54298583.3020100@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>, davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <54298583.3020100@cogentembedded.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29 September 2014 18:14, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
>>
>> index a476b99..19e79f0 100644
>> --- a/net/netfilter/nf_tables_api.c
>> +++ b/net/netfilter/nf_tables_api.c
>> @@ -2344,6 +2344,11 @@ static int nf_tables_fill_set(struct sk_buff =
*skb,
>> const struct nft_ctx *ctx,
>>                         goto nla_put_failure;
>>         }
>>
>> +       if (set->policy !=3D NFT_SET_POL_PERFORMANCE) {
>> +               if (nla_put_be32(skb, NFTA_SET_POLICY,
>> htonl(set->policy)))
>> +                       goto nla_put_failure;
>
>
>    Why not fold these two *if* stetement into a single one?
>

I don't have any preference.

Should I send a patch to change it?

regards.
--=20
Arturo Borrero Gonz=C3=A1lez
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

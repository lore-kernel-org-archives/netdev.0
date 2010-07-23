From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 13:43:25 +0800
Message-ID: <AANLkTilvne1U-SaCp9SK7gA9Q_ZJCZRO47buCb_ziuqm@mail.gmail.com>
References: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>
	<1279862843.2482.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279862843.2482.16.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 23, 2010 at 1:27 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 23 juillet 2010 =E0 12:54 +0800, Changli Gao a =E9crit :
>> This patch should be applied after my another patch:
>> http://patchwork.ozlabs.org/patch/59729/
>>
>> xt_quota: don't copy quota back to userspace
>>
>> In nowadays, table entries are per-cpu variables, so it don't make a=
ny sense to
>> copy quota back to one of the variable instances. To keep things sim=
ple, this
>> patch undo the copy.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> This looks the wrong way to fix this problem.
>
> Also Changli, could you please _not_ include the title of your patche=
s
> inside the Changelog ? This is useless.
>

Thanks. I remembered  some document mentioned a summary line was
needed. I'll follow your advice.


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

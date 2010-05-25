From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Wed, 26 May 2010 06:52:45 +0800
Message-ID: <AANLkTild6hAh1PPeHj_Q06k8drq-O9O9Nc48Urknm4in@mail.gmail.com>
References: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
	<alpine.DEB.2.00.1005251353370.20667@blackhole.kfki.hu> <AANLkTilbZ4PE7c6pep4bYvAx7ydx78qb4tKJi0vCjD52@mail.gmail.com>
	<alpine.DEB.2.00.1005252100500.21791@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1005252100500.21791@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 26, 2010 at 3:03 AM, Jozsef Kadlecsik
<kadlec@blackhole.kfki.hu> wrote:
>>
>> Yea. Only MSS option is =C2=A0supported. But it is better than being=
 DoSed.
>> And you can set a threshold for SYNPROXY with limit match, then ther=
e
>> isn't any difference if there isn't any SYN-flood attack.
>
> If I (have to) limit SYNPROXY, why shouldn't I better limit the SYN
> packets directly instead?
>

Without SYNPROXY, you have to drop the over limit SYN packets, and
maybe normal SYN packets are dropped.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

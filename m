From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 4/5] net: add CONFIG_NET_INGRESS to enable ingress filtering
Date: Wed, 13 May 2015 09:55:36 -0700
Message-ID: <55538208.2090504@plumgrid.com>
References: <1431533978-26901-1-git-send-email-pablo@netfilter.org> <1431533978-26901-5-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jhs@mojatatu.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com, kaber@trash.net
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1431533978-26901-5-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/13/15 9:19 AM, Pablo Neira Ayuso wrote:
> This new config switch enables the ingress filtering infrastructure that is
> controlled through the ingress_needed static key. This prepares the
> introduction of the Netfilter ingress hook that resides under this unique
> static key.
>
> Note that CONFIG_SCH_INGRESS automatically selects this, that should be no
> problem since this also depends on CONFIG_NET_CLS_ACT.
>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Looks good to me.

Acked-by: Alexei Starovoitov <ast@plumgrid.com>


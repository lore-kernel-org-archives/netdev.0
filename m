From: Patrick McHardy <kaber@trash.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 26 Mar 2009 15:18:46 +0100
Message-ID: <49CB8EC6.6070705@trash.net>
References: <20090326141405.GA25404@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090326141405.GA25404@ioremap.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> +static void xt_osf_send_connector(const struct xt_osf_user_finger *f,
> +				   const struct sk_buff *skb)
> +{
> +#if 1
> +	return;
> +#else

Please get rid of the connector remains.

The decision whether to still merge it in this window is up to Dave.
I already have some late-comers queued up that I hope to still get
in and I don't want to unnecessarily decrease my chances :)

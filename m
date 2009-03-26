From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 26 Mar 2009 17:59:46 +0300
Message-ID: <20090326145946.GA28563@ioremap.net>
References: <20090326141405.GA25404@ioremap.net> <49CB8EC6.6070705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49CB8EC6.6070705@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 26, 2009 at 03:18:46PM +0100, Patrick McHardy (kaber@trash.net) wrote:
> Evgeniy Polyakov wrote:
> >+static void xt_osf_send_connector(const struct xt_osf_user_finger *f,
> >+				   const struct sk_buff *skb)
> >+{
> >+#if 1
> >+	return;
> >+#else
> 
> Please get rid of the connector remains.
> 
> The decision whether to still merge it in this window is up to Dave.
> I already have some late-comers queued up that I hope to still get
> in and I don't want to unnecessarily decrease my chances :)

I left that chunk to the case when we will want to send notifications to
the userspace, right now we do not , so it is commented. And yes, names
were not changed :)

If Dave will refuse to pull it, please queue it into the netfilter tree
for the next merge window update, since I will miss it almost for sure.

-- 
	Evgeniy Polyakov

From: "David S. Miller" <davem@davemloft.net>
Subject: (usagi-users 03613) Re: [PATCH] [NET]: NETFILTER: remove duplicated operation and fix
 order in skb_clone().
Date: Sun, 19 Feb 2006 22:32:33 -0800 (PST)
Message-ID: <20060219.223233.65613202.davem@davemloft.net>
References: <43F5A7B2.90803@6wind.com>
	<20060217.215101.09874309.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-users@linux-ipv6.org, olivier.matz@6wind.com
Return-path: <usagi-users-admin@linux-ipv6.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060217.215101.09874309.yoshfuji@linux-ipv6.org>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Fri, 17 Feb 2006 21:51:01 +0900 (JST)

> [NET]: NETFILTER: remove duplicated lines and fix order in skb_clone().
> 
> Some of netfilter-related members are initalized / copied twice in
> skb_clone(). Remove one. Pointed out by Olivier MATZ <olivier.matz@6wind.com>.
> 
> And this patch also fixes order of copying / clearing members.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Patch applied to net-2.6, thank you very much.

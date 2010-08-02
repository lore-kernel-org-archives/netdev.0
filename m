From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_conntrack_extend: introduce __nf_ct_ext_exist()
Date: Mon, 02 Aug 2010 17:07:05 +0200
Message-ID: <4C56DF19.4080502@trash.net>
References: <1280068734-5332-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280068734-5332-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 25.07.2010 16:38, Changli Gao wrote:
> some users of nf_ct_ext_exist() know ct->ext isn't NULL. For these users, the
> check for ct->ext isn't necessary, the function __nf_ct_ext_exist() can be
> used instead.
> 
> the type of the return value of nf_ct_ext_exist() is changed to bool.

Applied, thanks.

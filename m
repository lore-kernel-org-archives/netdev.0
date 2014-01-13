From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable bind() to assign an anycast address
Date: Mon, 13 Jan 2014 08:43:14 -0800 (PST)
Message-ID: <1389631394.99071.YahooMailBasic@web125501.mail.ne1.yahoo.com>
References: <1389377544-3119-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm31.bullet.mail.ne1.yahoo.com ([98.138.229.24]:33099 "EHLO
	nm31.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753146AbaAMQqE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 11:46:04 -0500
In-Reply-To: <1389377544-3119-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 1/10/14, Francois-Xavier Le Bail <fx.lebail@yahoo.com> wrote:

> - Add ipv6_chk_acast_addr_src() to check if an anycast address is link-local
>   on given interface or is global (on any interface).
> - Use it in inet6_bind().
> 
> Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
> ---

I will divide this patch in 2 patches : one for adding ipv6_chk_acast_addr_src(), one (v2) for updating bind().

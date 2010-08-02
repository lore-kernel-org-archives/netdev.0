From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2 2/2] nf_nat: don't check if the tuple is unique when
 there isn't any other choice
Date: Mon, 02 Aug 2010 17:36:27 +0200
Message-ID: <4C56E5FB.4070406@trash.net>
References: <1280560164-30783-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280560164-30783-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 31.07.2010 09:09, Changli Gao wrote:
> the tuple got from unique_tuple() doesn't need to be really unique, so the
> check for the unique tuple isn't necessary, when there isn't any other
> choice. Eliminating the unnecessary nf_nat_used_tuple() can save some CPU
> cycles too.

Applied.

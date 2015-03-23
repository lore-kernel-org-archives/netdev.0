From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Mon, 23 Mar 2015 08:43:09 -0700
Message-ID: <1427125389.16851.23.camel@perches.com>
References: <20150323140841.0b807b95@canb.auug.org.au>
	 <20150323124723.GA6740@salvia> <1427115331.16851.11.camel@perches.com>
	 <20150323130638.GA6857@salvia> <1427117031.16851.16.camel@perches.com>
	 <20150324003828.0eac53d9@canb.auug.org.au> <20150323135235.GA7595@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150323135235.GA7595@salvia>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-03-23 at 14:52 +0100, Pablo Neira Ayuso wrote:
> I would also prefer if you include the explicit header files in that
> patch too. Could you send us a v2? Please, Cc:
> netfilter-devel@vger.kernel.org

As I wrote to Stephen, I'd prefer to #include
kernel.h where it's not already specified.

net/netfilter/nft_log.c does, every other
modified file doesn't.

Is that OK with you?

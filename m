From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] netfilter: Remove uses of return value of
 seq_printf/puts/putc
Date: Tue, 17 Feb 2015 17:20:14 -0800
Message-ID: <1424222414.25416.21.camel@perches.com>
References: <1424136309.8287.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424136309.8287.8.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-16 at 17:25 -0800, Joe Perches wrote:
> These functions are soon going to return void so remove the
> return value uses.
> 
> Convert the return value to test seq_has_overflowed() instead.

(sorry 'bout that, overly sensitive mouse)

Please do not apply.

These need conversions to "return 0"
not "return seq_has_overflowed()";

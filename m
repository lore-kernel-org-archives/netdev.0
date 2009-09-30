From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25: Fix possible oops in ax25_make_new
Date: Wed, 30 Sep 2009 16:44:51 -0700 (PDT)
Message-ID: <20090930.164451.234667079.davem@davemloft.net>
References: <20090925131038.GA14778@ff.dom.local>
	<20090925134052.GA1661@linux-mips.org>
	<20090927205701.GA7205@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, f6bvp@free.fr, bernard.pidoux@upmc.fr,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090927205701.GA7205@del.dom.local>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 27 Sep 2009 22:57:02 +0200

> In ax25_make_new, if kmemdup of digipeat returns an error, there would
> be an oops in sk_free while calling sk_destruct, because sk_protinfo
> is NULL at the moment; move sk->sk_destruct initialization after this.
> 
> BTW of reported-by: Bernard Pidoux F6BVP <f6bvp@free.fr>
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Applied and queued up for -stable, thanks!

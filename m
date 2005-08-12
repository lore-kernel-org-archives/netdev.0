From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 3/8] netpoll: e1000 netpoll tweak
Date: Fri, 12 Aug 2005 12:10:38 -0700 (PDT)
Message-ID: <20050812.121038.23012223.davem@davemloft.net>
References: <3.502409567@selenic.com>
	<4.502409567@selenic.com>
	<56a8daef0508121202172bcd17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, akpm@osdl.com, ak@suse.de, jmoyer@redhat.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org, mingo@elte.hu,
        john.ronciak@intel.com, rostedt@goodmis.org
Return-path: <netdev-bounce@oss.sgi.com>
To: john.ronciak@gmail.com
In-Reply-To: <56a8daef0508121202172bcd17@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: John Ronciak <john.ronciak@gmail.com>
Subject: Re: [PATCH 3/8] netpoll: e1000 netpoll tweak
Date: Fri, 12 Aug 2005 12:02:03 -0700

> Sorry this reply was to go to the whole list but only made it to Matt.
> 
> The e1000_intr() routine already calls e1000_clean_tx_irq().  So
> what's the point of this patch?  Am I missing something?

e1000_intr() does not call e1000_clean_tx_irq() when NAPI
is enabled.

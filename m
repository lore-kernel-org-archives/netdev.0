From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/icmp: restore source address if packet is NATed
Date: Sun, 25 Jun 2017 21:48:29 -0400 (EDT)
Message-ID: <20170625.214829.1020312191989118292.davem@davemloft.net>
References: <20170624021727.17835-1-Jason@zx2c4.com>
        <20170625.114927.1055286919675288173.davem@davemloft.net>
        <CAHmME9pJ3bFR+hk6zb71SYzgamy7qHS7TY20qdw3EcCHp5Ghsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pJ3bFR+hk6zb71SYzgamy7qHS7TY20qdw3EcCHp5Ghsw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Mon, 26 Jun 2017 00:52:09 +0200

> On Sun, Jun 25, 2017 at 5:49 PM, David Miller <davem@davemloft.net> wrote:
>> You definitely can't just rewrite header fields here either.  The
>> SKB could be shared, for example.
> 
> I was afraid of that. It's easy to rework this particular patch,
> though, if you're still interested in the crufty bolt on approach...
> But I think I should investigate the netfilter-only approach instead,
> as you suggested.

I highly encourage you to continue pursuing the netfilter based
approach, and to also discuss it on netfilter-devel which will
hit more capable minds than just here on netdev.

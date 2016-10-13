From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Thu, 13 Oct 2016 08:02:04 +0200
Message-ID: <1476338524.4904.1.camel@sipsolutions.net>
References: <20161010150358.GA514@swordfish>
         <20161010153050.GA836@swordfish>
         <1476263106.5271.23.camel@sipsolutions.net>
         <20161012141245.GA436@swordfish>
         <1476282127.5271.30.camel@sipsolutions.net>
         <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
         (sfid-20161013_074011_616875_45F10514)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com> (sfid-20161013_074011_616875_45F10514)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-10-12 at 22:39 -0700, Andy Lutomirski wrote:

> In a pinch, I have these patches sitting around:
> 
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=x86/vmap_stack&id=0a39cfa6fbb5d5635c85253cc7d6b44b54822afd
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=x86/vmap_stack&id=bf8cfa200b5a01383ea39fc8ce2f32909767baa8

That truly sounds like something we'd rather avoid in the TX/RX paths
though, which should perform well.

> I don't like them, though.  I think it's rather silly that we can't
> just pass virtual addresses to the crypto code.

I don't really understand it either, hence my question about the actual
crash. I'll try to reproduce it in a VM.

johannes

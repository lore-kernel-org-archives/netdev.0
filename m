From: Andi Kleen <ak@muc.de>
Subject: Re: udp.c
Date: Tue, 14 Jun 2005 01:53:56 +0200
Message-ID: <m1fyvlbyp7.fsf@muc.de>
References: <E1Dhwho-0001mn-00@gondolin.me.apana.org.au>
	<20050613.145716.88477054.davem@davemloft.net>
	<20050613230422.GA7269@gondor.apana.org.au>
	<20050613.162052.41635836.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261496AbVFMX4G@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050613.162052.41635836.davem@davemloft.net> (David S.
 Miller's message of "Mon, 13 Jun 2005 16:20:52 -0700 (PDT)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 14 Jun 2005 09:04:22 +1000
>
>> On Mon, Jun 13, 2005 at 02:57:16PM -0700, David S. Miller wrote:
>> > From: Herbert Xu <herbert@gondor.apana.org.au>
>> > Date: Tue, 14 Jun 2005 07:42:52 +1000
>> > 
>> > > It'll dump the stack anyway if we just make it a NULL pointer.
>> > 
>> > Some platforms don't handle that very cleanly, for example
>> > it may be necessary to have something mapped at page zero
>> > for one reason or another.
>> 
>> Are there any existing platforms that do that in kernel mode?
>
> X86 did, especially during bootup, for a long time.

Still does, as does x86-64, but actually it could be changed now using
change_page_attr (and then later undoing it). Is it worth it?

-Andi

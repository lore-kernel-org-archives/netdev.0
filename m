From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: Doing crypto in small stack buffers (bluetooth vs vmalloc-stack
 crash, etc)
Date: Thu, 23 Jun 2016 15:11:00 -0700
Message-ID: <CALCETrWRyai42BbQ213TzmZ9KwQhAD2eEoeCeR+6NPSC4O4BZg@mail.gmail.com>
References: <CALCETrVJzzKkRsSbgsUmVd_+ArKEgoRSVdG1tVp7CXzFoPyVgA@mail.gmail.com>
 <20160622004214.GA27134@gondor.apana.org.au> <CALCETrUnzasc+c5Dxmw+g6U07dTNU4RF0ug1bHj8j2en+7Xj1A@mail.gmail.com>
 <CALCETrUWyNz91WO6O3dNb+YELeZy5q4+oTo6dLRR67P2WvBB8g@mail.gmail.com>
 <CALCETrXJAvtty-zrjZR0URyT92rMZ4HhiTLtd4r5CzFjZOj=-Q@mail.gmail.com>
 <20160623034825.GB7819@gondor.apana.org.au> <20160623064137.GA8958@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>, linux-bluetooth@vger.kernel.org,
	Johan Hedberg <johan.hedberg@gmail.com>,
	Gustavo Padovan <gustavo@padovan.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	linux-crypto@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20160623064137.GA8958@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 22, 2016 at 11:41 PM, Herbert Xu
<herbert@gondor.apana.org.au> wrote:
> On Thu, Jun 23, 2016 at 11:48:25AM +0800, Herbert Xu wrote:
>>
>> No we never had such an API in the kernel.  However, I see that
>> rxkad does some pretty silly things and we should be able to avoid
>> using the stack in pretty much all cases.  Let me try to come up with
>> something.
>
> Here it is:
>
> ---8<---
> Subject: rxrpc: Avoid using stack memory in SG lists in rxkad

Looks reasonable to me.  Unless anyone tells me otherwise, my plan is
to queue it in my virtually-mapped stack series and to ask Ingo to
apply it via -tip.

If it went in via the networking tree, that would work as well, but it
would introduce a bisectability problem.

Thanks!

--Andy

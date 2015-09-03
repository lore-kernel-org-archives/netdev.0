From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 3 Sep 2015 14:04:26 -0700
Message-ID: <CA+55aFzWY=2-JSZf+xBy6d=fdDHAFV5ABiyXeG3xGs7qO=ySsA@mail.gmail.com>
References: <20150902.223522.1792493140210966693.davem@davemloft.net>
	<CA+55aFx=xh4+vCNOgwXyfeV-t=6anXimqBxH_i71RjYy+Gy9-w@mail.gmail.com>
	<20150903.104032.767889134756094076.davem@davemloft.net>
	<CA+55aFxtD2VYW2R0JwjFkZkvzQzcN7qK3m6ReR+BBXtfyDHx7g@mail.gmail.com>
	<1441305296.9666.14.camel@perches.com>
	<alpine.DEB.2.02.1509032121120.2035@localhost6.localdomain6>
	<CA+55aFy9L9U+bkk_VLRdWmepRH8LRkDw1sBo8t-byKUTZKWwBw@mail.gmail.com>
	<alpine.DEB.2.02.1509032250451.2035@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Joe Perches <joe@perches.com>, David Miller <davem@davemloft.net>,
	Lorenzo Bianconi <lorenzo.bianconi83@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1509032250451.2035@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 3, 2015 at 1:55 PM, Julia Lawall <julia.lawall@lip6.fr> wrote:
>
> There are 32 2-dimensional arrays in function parameters, and 1
> 3-dimensional array.  No 4-dimensional arrays.  I didn't check past that.
> None of these has a sizeof or ARRAY_SIZE.
>
> The three dimensional array is here: drivers/media/dvb-frontends/stv0367.c

Ok. That actually looks like a valid use of the C function argument
array passing semantics. It's rather much simpler than exposing the
pointers.

So I guess we don't really end up wanting to disallow this, and the
new gcc array sizeof warning is good enough.

Thanks for running the analysis so that I didn't have to look at it ;)

                       Linus

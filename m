From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: irq_fpu_usable() is false in ndo_start_xmit() for UDP packets
Date: Mon, 16 Nov 2015 22:37:45 +0100
Message-ID: <CAHmME9paDGfgf7NxYsC-MmBWdLeK+Uj2OV5X8FNxUoABObuXuA@mail.gmail.com>
References: <CAHmME9o3s5iTZ4gcFVQ1xTu9PaaLjkEGcvhJRF+S=0GugxhQ8Q@mail.gmail.com>
	<20151116.161746.1472467067664450149.davem@davemloft.net>
	<CAHmME9qDJnfJgerxwwG8_dMvse7oim=sDdPzQo=DRi_S0Ym=Ew@mail.gmail.com>
	<20151116.163327.500953242093794786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151116.163327.500953242093794786.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 16, 2015 at 10:33 PM, David Miller <davem@davemloft.net> wrote:
> Someone already did a Linux implemenation of exactly that two decades
> ago, we rejected that design and did what we did.

It's not exactly IPSec though, so don't worry. It's a totally new
thing that combines a lot of different recent ideas, in the virtual
networking arena as well as in crypto. *It's going to be cool.* And
I'm determined to please you with the design and implementation in the
end. So let me finish off my first implementation, and then we can do
some back and forth on the overall high level ideas and iron out some
of the potential implementation issues that you find. I'll incorporate
your feedback iteratively until it's in a state that you like. I've
been working on this day and night for months, and I'm *almost* there.
Bare with me a little longer, and expect a nice "[RFC]" email to be
sent your way soon.

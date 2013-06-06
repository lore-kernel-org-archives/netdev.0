From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 5/5] net: Block MSG_CMSG_COMPAT in send(m)msg and
 recv(m)msg
Date: Wed, 05 Jun 2013 21:35:25 -0700
Message-ID: <1370493325.24311.332.camel@edumazet-glaptop>
References: <cover.1369177867.git.luto@amacapital.net>
	 <aa015609319786835bcab445d507faa75c11f111.1369177867.git.luto@amacapital.net>
	 <CAEjGV6xcF776C6N6VxeMY0Vyk+X51oNixdbN42-xkWjQOaMEQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto@amacapital.net>,
	linux-kernel@vger.kernel.org, x86@kernel.org,
	trinity@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Anton Blanchard <anton@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Linux PPC dev <linuxppc-dev@ozlabs.org>,
	torvalds@linux-foundation.org
To: Michael Neuling <mikey@neuling.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEjGV6xcF776C6N6VxeMY0Vyk+X51oNixdbN42-xkWjQOaMEQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-06-06 at 12:56 +1000, Michael Neuling wrote:
> On Thu, May 23, 2013 at 7:07 AM, Andy Lutomirski <luto@amacapital.net> wrote:
> > MSG_CMSG_COMPAT is (AFAIK) not intended to be part of the API --
> > it's a hack that steals a bit to indicate to other networking code
> > that a compat entry was used.  So don't allow it from a non-compat
> > syscall.
> 
> Dave & Linus
> 
> This is causing a regression on 64bit powerpc with 32bit usermode.
> When I hit userspace, udev is broken and I suspect all networking is
> broken as well.
> 
> Can we please revert 1be374a0518a288147c6a7398792583200a67261 upstream?
> 

It seems to also break x86_64, if using 32bit usermode.

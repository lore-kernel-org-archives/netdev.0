From: Song Wang <wsonguci@yahoo.com>
Subject: Re: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: Wed, 29 Sep 2004 12:37:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929193721.81884.qmail@web40006.mail.yahoo.com>
References: <1095334258.1065.158.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Song Wang <wsonguci@yahoo.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1095334258.1065.158.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, jamal,

Could you please kindly point where the gettimeofday
patch is? Is it in 2.6.8.1 kernel?

BTW, what is the packet size for you performance
number, 64 bytes?

I appreciate it.

-Song
--- jamal <hadi@cyberus.ca> wrote:

> On Wed, 2004-09-15 at 14:08, David S. Miller wrote:
> > On Wed, 15 Sep 2004 11:06:03 -0700 (PDT)
> > Song Wang <wsonguci@yahoo.com> wrote:
> > 
> > > The mips CPU on the board is MIPS32 compatible.
> > > I don't think it's NAPI based.
> > 
> > NAPI is an attribute of the network adapter, not
> > the cpu.
> > 
> > Although I would very much anticipate this being
> > a MIPS or network adapter specific problem since
> > on x86 routing is pretty fast in 2.6.x
> 
> Note, I could hit 4-500Kpps on a bcom sb1250 800Mhz;
> trying to simulate
> Andis gettimeofday changes (which are in 2.6 since i
> havent seen a 2.6
> port for that board ) gives another 100Kpps. Theres
> still room for
> improvement just havent had time.
> You are right though it could be a 2.6.x arch
> specific issue. Bacchus?
> 
> cheers,
> jamal
> 
> 



		
_______________________________
Do you Yahoo!?
Declare Yourself - Register online to vote today!
http://vote.yahoo.com

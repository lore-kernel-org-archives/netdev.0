From: jamal <hadi@cyberus.ca>
Subject: Re: [Routing] Performance Comparison between 2.6 and 2.4 kernel
Date: 16 Sep 2004 07:30:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095334258.1065.158.camel@jzny.localdomain>
References: <1094868693.1041.86.camel@jzny.localdomain>
	 <20040915180603.98079.qmail@web40007.mail.yahoo.com>
	 <20040915110858.125cea28.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Song Wang <wsonguci@yahoo.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040915110858.125cea28.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-15 at 14:08, David S. Miller wrote:
> On Wed, 15 Sep 2004 11:06:03 -0700 (PDT)
> Song Wang <wsonguci@yahoo.com> wrote:
> 
> > The mips CPU on the board is MIPS32 compatible.
> > I don't think it's NAPI based.
> 
> NAPI is an attribute of the network adapter, not
> the cpu.
> 
> Although I would very much anticipate this being
> a MIPS or network adapter specific problem since
> on x86 routing is pretty fast in 2.6.x

Note, I could hit 4-500Kpps on a bcom sb1250 800Mhz; trying to simulate
Andis gettimeofday changes (which are in 2.6 since i havent seen a 2.6
port for that board ) gives another 100Kpps. Theres still room for
improvement just havent had time.
You are right though it could be a 2.6.x arch specific issue. Bacchus?

cheers,
jamal

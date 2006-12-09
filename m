From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour  bits
Date: Fri, 08 Dec 2006 16:43:45 -0800 (PST)
Message-ID: <20061208.164345.71119524.davem@davemloft.net>
References: <20061208213614.GA28903@nevyn.them.org> 	<20061208.134752.131916271.davem@davemloft.net> 	<20061208215206.GA29601@nevyn.them.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, tgraf@suug.ch, dwmw2@infradead.org,  joseph@codesourcery.com, netdev@vger.kernel.org,  libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <libc-alpha-return-19638-glibc-alpha=m.gmane.org@sourceware.org>
To: drow@false.org
In-Reply-To: <20061208215206.GA29601@nevyn.them.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

From: Daniel Jacobowitz <drow@false.org>
Date: Fri, 8 Dec 2006 16:52:06 -0500

> On Fri, Dec 08, 2006 at 01:47:52PM -0800, David Miller wrote:
> > > > > The _RTA and _PAYLOAD-macros are also part of userspace headers and need to be
> > > > > restored. Both dhcpclient and quagga need at least IFA_RTA and IFLA_RTA to
> > > > > compile, but there may be more macros than in the following patch. You may want
> > > > > to look at keepalived, iproute, ...
> 
> > GLIBC does not use them.
> 
> Aren't these the ones you're talking about?
> 
> sysdeps/unix/sysv/linux/check_pf.c:                   struct rtattr *rta = IFA_RTA (ifam);

hohum... guess we'll need to bring back that crap too...

i'll take care of this

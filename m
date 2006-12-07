From: David Miller <davem@davemloft.net>
Subject: Re: Kernel header changes break glibc build
Date: Thu, 07 Dec 2006 02:51:40 -0800 (PST)
Message-ID: <20061207.025140.75779834.davem@davemloft.net>
References: <200612062033.34754.stefan@loplof.de> 	<20061206.165638.30168567.davem@davemloft.net> 	<20061207104721.GI8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefan@loplof.de, dwmw2@infradead.org, joseph@codesourcery.com,  netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <libc-alpha-return-19624-glibc-alpha=m.gmane.org@sourceware.org>
To: tgraf@suug.ch
In-Reply-To: <20061207104721.GI8693@postel.suug.ch>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 7 Dec 2006 11:47:21 +0100

> * David Miller <davem@davemloft.net> 2006-12-06 16:56
> > That's enough for me.
> > 
> > Thomas we need to restore things to how they were before.
> > If that means including if_addr.h from rtnetlink.h so be it.
> > 
> > We can't break shit like this, there are no excuses, especially
> > now that we properly frob the headers for userspace consumption
> > in the kernel tree.
> 
> So you want to restore IFLA_RTA/IFLA_PAYLOAD etc. as well?

Just fixup the if_addr.h include for now.

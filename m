From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 09 Dec 2006 22:02:55 +0000
Message-ID: <1165701775.27042.9.camel@shinybook.infradead.org>
References: <20061208.134752.131916271.davem@davemloft.net> 	 <200612091249.39302.stefan@loplof.de> 	 <20061209125533.GO8693@postel.suug.ch> 	 <200612091559.05232.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,  drow@false.org, joseph@codesourcery.com, netdev@vger.kernel.org,  libc-alpha@sourceware.org, akpm@osdl.org, linux-kernel@vger.kernel.org
Return-path: <libc-alpha-return-19649-glibc-alpha=m.gmane.org@sourceware.org>
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200612091559.05232.stefan@loplof.de>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-12-09 at 15:58 +0100, Stefan Rompf wrote:
> But when even glibc needs internal compat headers to compile with the second 
> kernel version that provides userspace headers, what is the long-term - even 
> mid-term - perspective of make headers_install then?

We've only _just_ started paying attention to what we export. I tried to
keep the initial cut of headers_install very simple and uncontentious --
sticking to implementation, and not policy. So I didn't do a
particularly thorough cull of stuff that we shouldn't be exposing --
it's expected that we may lose _some_ more stuff.

But breaking userspace like _this_ isn't acceptable, and we're not doing
it.

-- 
dwmw2

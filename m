From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: iproute2 and 2.6.9 kernel headers (was Re: [ANNOUNCE] iproute2
	2.6.9-041019)
Date: Wed, 20 Oct 2004 13:19:48 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1098274788.3872.90.camel@baythorne.infradead.org>
References: <41758014.4080502@osdl.org>
	 <Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
	 <20041020070017.GA19899@sunbeam.de.gnumonks.org>
	 <20041020094123.GF19899@sunbeam.de.gnumonks.org>
	 <1098268885.3872.81.camel@baythorne.infradead.org>
	 <4176517C.4090504@arcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>,
	Jeff Chua <jeffchua@silk.corp.fedex.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@oss.sgi.com, linux-net@vger.kernel.org,
	LARTC@mailman.ds9a.nl
Return-path: <linux-net-owner@vger.kernel.org>
To: David Vrabel <dvrabel@arcom.com>
In-Reply-To: <4176517C.4090504@arcom.com>
List-Id: netdev.vger.kernel.org

On Wed, 2004-10-20 at 12:52 +0100, David Vrabel wrote:
> David Woodhouse wrote:
> > 
> > The time has come to fix it properly instead. Anything which these tools
> > actually need from the kernel headers should be moved into a separate
> > header file (still in the kernel source) which is usable from _both_
> > kernel and userspace.
> 
> Isn't this what linux-libc-headers is for?

The separate linux-libc-headers is a hack, which will be able to die
once we properly clean up the kernel headers into those which are
'exported' and those which are private.

> > It should use standard types (like uint16_t etc)
> 
> Why doesn't the kernel use these standard types also?

Archaic personal preference. Inside the kernel that's fair enough.

-- 
dwmw2



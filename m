From: Andi Kleen <ak@suse.de>
Subject: Re: Patch: IPv6/AMD64: bug in net/ipv6/ndisc.c
Date: Fri, 30 Jan 2004 01:40:31 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040130014031.31ec050f.ak@suse.de>
References: <20040129221538.J24747@fi.muni.cz>
	<20040130.083743.20740540.yoshfuji@linux-ipv6.org>
	<20040129153953.3dd2cd23.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: yoshfuji@linux-ipv6.org, kas@informatics.muni.cz,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040129153953.3dd2cd23.davem@redhat.com>
List-Id: netdev.vger.kernel.org

On Thu, 29 Jan 2004 15:39:53 -0800
"David S. Miller" <davem@redhat.com> wrote:

> On Fri, 30 Jan 2004 08:37:43 +0900 (JST)
> YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:
> 
> > For long term solution, I think it is better to store timing variables 
> > in "unsinged long" type instead of int. 
> 
> I think this is the only fix to even consider, even in the short term.
> The macro suggested is just too much of a hack. :)
> 
> We can just ignore the silly warning until we are able to find time
> to do the correct fix.


Fine by me. I've been ignoring it forever. But don't you see it on sparc64 too?

FWIW only IPv6, keyboard driver and ACPI are spewing warnings on x86-64 in a defconfig
compile.

-Andi

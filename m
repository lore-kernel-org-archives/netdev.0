From: Andi Kleen <ak@suse.de>
Subject: Re: do_IRQ: stack overflow: 872..
Date: Sat, 18 Dec 2004 12:14:20 +0100
Message-ID: <20041218111420.GE338@wotan.suse.de>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel> <p73zn0ccaee.fsf@verdi.suse.de> <1103368330.3566.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, Crazy AMD K7 <snort2004@mail.ru>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262205AbULRLOX@vger.kernel.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <1103368330.3566.15.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The bridge-nf code does not use recursive function calls and there is no
> long consecutive function calling. Furthermore, there is no function in
> the bridge-nf code that uses a large part of the stack.

Just take a look at the backtrace in the original post. It clearly
shows a problem. And it points strongly towards br-netfilter.

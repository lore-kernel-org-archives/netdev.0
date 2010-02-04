From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: netfilter/iptables and network interface names
Date: Thu, 4 Feb 2010 15:29:01 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1002041528300.13435@obet.zrqbmnf.qr>
References: <4B6AC467.7020209@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>
To: Thomas Woerner <twoerner@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B6AC467.7020209@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-02-04 13:58, Thomas Woerner wrote:

> Hello,
>
> I just fell over network interface definitions in kernel and
> netfilter/iptables.
>
> Interfaces names in the kernel have few limits: Only spaces and slashes are not
> allowed, but everything else, even Ctrl characters are.
>
> In iptables, there are other limits: Colon, exclamation mark and asterisk are
> not allowed. The plus is treated special for matching. But what will be matched
> if the interface starts with or contains a plus?
>
> iptables allows to use interfaces containing spaces and slashes. iptables-save
> is not escaping interface names. The interface "+" will be treated as no
> interface limit at all and will be dropped, therefore all interfaces match.
>
> I think there should be some discussion about interface names and limits in
> kernel and netfilter/iptables.
>
> What do you think?

I think we should cc netdev for a start.

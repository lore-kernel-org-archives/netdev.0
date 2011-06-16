From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] iptables: document IPv6 TOS mangling bug in old Linux
 kernels
Date: Thu, 16 Jun 2011 17:06:41 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1106161705300.10015@frira.zrqbmnf.qr>
References: <1307320871-31770-1-git-send-email-pablo@netfilter.org>  <1307320871-31770-2-git-send-email-pablo@netfilter.org>  <BANLkTikAs7fN2JQJTUwQHAYPPGMf8i9uEA@mail.gmail.com>  <alpine.LNX.2.01.1106061618370.17430@frira.zrqbmnf.qr>
 <1308213411.4062.22.camel@nausicaa>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>, Maciej <zenczykowski@gmail.com>,
	Pablo Neira Aysuo <pablo@netfilter.org>,
	Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1308213411.4062.22.camel@nausicaa>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2011-06-16 10:36, Fernando Luis Vazquez Cao wrote:

>Jan, Patrick,
>
>I would like to get this bug in old Linux kernels documented in the
>iptables man page, since it is pretty serious. The fix made into 2.6.39
>and I would like to have it backported to 2.6.32-longterm and
>2.6.33-longterm. If you disagree with the backport to -longterm please
>let me know, I would update the patch accordingly.

> .SH BUGS
> Bugs?  What's this? ;-)
>+.PP
> Well... the counters are not reliable on sparc64.
>+.PP
>+In Linux kernels up to and including 2.6.38, with the exception of longterm
>+releases 2.6.32.42 (or later) and 2.6.33.15 (or later), there is a bug whereby
>+IPv6 TOS mangling does not behave as documented and differs from the IPv4
>+version. The TOS mask indicates the bits one wants to zero out, so it needs to
>+be inverted before applying it to the original TOS field. However, the
>+aformentioned kernels forgo the inversion which breaks --set-tos and its
>+mnemonics.
>+.PP
>+You might also want to have a look at http://bugzilla.netfilter.org/
> .SH COMPATIBILITY WITH IPCHAINS
> This \fBip6tables\fP
> is very similar to ipchains by Rusty Russell.  The main difference is

I feel this should be listed in the TOS page, to avoid duplication.


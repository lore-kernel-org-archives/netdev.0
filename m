From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH v5] Gemini: Gigabit ethernet driver
Date: Sat, 5 Feb 2011 14:19:01 +0100
Message-ID: <20110205131901.GA14145@rere.qmqm.pl>
References: <20101230083905.5A8EB13909@rere.qmqm.pl> <20110126232419.4794513909@rere.qmqm.pl> <20110128.143159.48506419.davem@davemloft.net> <20110202171814.GA10458@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110202171814.GA10458@rere.qmqm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 02, 2011 at 06:18:14PM +0100, Micha=B3 Miros=B3aw wrote:
> If I make it buildable (NOT working) on other archs is it enough I ad=
d
> Kconfig dependency on (ARCH_GEMINI || BROKEN) to allow it to be
> build-tested there?

Hmm. CONFIG_BROKEN is not easily selectable anymore, so it's unlikely
that many people will even know about it. What's the correct way to
make a driver be built but not installed by default? I can use:

default m if ARCH_GEMINI
default n

But that will make it get installed on x86 allmodconfig even if it
won't ever work there - so will pollute modules for other arches
unless distribution managers remember that not every driver built
needs to be included.

Best Regards,
Micha=B3 Miros=B3aw

From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 6/9] snet: introduce snet_hooks.c and snet_hook.h
Date: Sun, 03 Jan 2010 23:26:48 +0100
Message-ID: <m2hbr2q0yf.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-7-git-send-email-sam@synack.fr>
	<20100102201303.GB27402@ioremap.net> <m2skanphoi.fsf@ssh.synack.fr>
	<20100103111611.36d01d30@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	linux-security-module@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100103111611.36d01d30@nehalam> (Stephen Hemminger's message of
	"Sun, 3 Jan 2010 11:16:11 -0800")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@vyatta.com> writes:

> On Sun, 03 Jan 2010 12:10:53 +0100
> Samir Bellabes <sam@synack.fr> wrote:
>
>> I know it's ugly, but code in security hooks are duplicated.
>> functions (inline or not), which replace this macros, will resulte of
>> having lots of parameters. macros with external object seems to be the
>> most simple at this point.
>
> Macro's with references to thing outside of the argument are just
> plain wrong. They introduce bugs that humans don't see.

right.
I will move this macros to inline functions.

thanks,
sam

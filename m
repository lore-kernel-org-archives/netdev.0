From: "David Stevens" <dlstevens@us.ibm.com>
Subject: Re: [PATCH] anycast support for IPv6, linux-2.5.31
Date: Fri, 30 Aug 2002 01:16:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <27374.724779702$1030695401@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, <linux-net@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Pekka,

You wrote:

>Before going too much down this path, I think one should write an Internet
>Draft about the proposed API (should be quite short & simple) and see what
>kind of response it has in the relevant working groups.

I don't disagree with that, for informational purposes, but it doesn't
conflict
with the RFC's, which of course don't cover API's, and don't specify any
interface
for anycasting.

However, my primary goal is to get anycasting support with an in-kernel
interface
in 2.5 before the freeze. :-) I used the setsockopt() API for testing, and
left it
in the patch for others to do the same. Though I think it's the right
approach, for
the reasons I mentioned, I'd rather see that portion pulled from the patch
if it's
controversial, than have the in-kernel interface and anycasting proper
delayed over
that.

The one use of anycast I'm aware of right now is for IPv6 mobility, which
needs the in-kernel interface. The
user-level interface is important for future applications, and a
reference-counted setsockopt() interface doesn't
mean we can't also have an ip/ifconfig interface for permanent anycast
addresses, too (the required anycast
addresses in this patch are permanent, for example). So I don't see it as
committing to one choice, but having
in-kernel anycast support (soon) I think is the more important first step.

                                    +-DLS

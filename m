From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: ipt_LOG: No space after prefix
Date: Sun, 22 Jan 2012 15:20:32 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1201221519200.10337@frira.zrqbmnf.qr>
References: <4F1C0719.1010609@nod.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4F1C0719.1010609@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 2012-01-22 13:54, Richard Weinberger wrote:

>Hi!
>
>Is there no space after prefix for specific reason?
>ipt_log_packet() is using this format string:
>"<%d>%sIN=%s OUT=%s "
>
>Using a prefix leads to a broken log entry like this one (prefix is "foo"):
>"fooIN=eth0 OUT= ..."
>I'm sure this breaks log analyzers.

Changing it now will break log analyzers as well. So you are better off 
leaving it as-is, because everybody who has observed that before you 
already knows about it.
(Also consider --log-prefix "", in which case I would not want to have 
a space.)

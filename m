From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: BUGs in skb_checksum_help() and skb_gso_segment() in 2.6.18-rc2
Date: Tue, 25 Jul 2006 19:29:39 +0400
Message-ID: <20060725152939.GA2246@2ka.mipt.ru>
References: <20060725151504.GA8947@irc.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:1242 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932439AbWGYP3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 11:29:49 -0400
To: Tomasz Torcz <zdzichu@irc.pl>
Content-Disposition: inline
In-Reply-To: <20060725151504.GA8947@irc.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2006 at 05:15:04PM +0200, Tomasz Torcz (zdzichu@irc.pl) wrote:
> BUG: warning at net/core/dev.c:1171/skb_checksum_help()
>  [<c010374a>] show_trace_log_lvl+0x51/0xe6
>  [<c01037e9>] show_trace+0xa/0xc
>  [<c01038b4>] dump_stack+0x13/0x15
>  [<c02b41c4>] skb_checksum_help+0x4d/0xeb
>  [<c02f9cbe>] ip_nat_fn+0x47/0x19a

It is not a bug, but remind to update nat helper function.

> -- 
> Tomasz Torcz                "Funeral in the morning, IDE hacking
> zdzichu@irc.-nie.spam-.pl    in the afternoon and evening." - Alan Cox

-- 
	Evgeniy Polyakov

From: Patrick Caulfield <patrick@tykepenguin.com>
Subject: Re: [2.6 patch] net/decnet/: misc possible cleanups
Date: Wed, 15 Dec 2004 10:56:46 +0000
Message-ID: <20041215105646.GB27420@tykepenguin.com>
References: <20041214125838.GC23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Steve Whitehouse <SteveW@ACM.org>, linux-decnet-user@lists.sourceforge.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
Content-Disposition: inline
In-Reply-To: <20041214125838.GC23151@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Dec 14, 2004 at 01:58:38PM +0100, Adrian Bunk wrote:
> The patch below contains the following possible cleanups:
> - make needlessly global code static
> - dn_fib.c: remove the write-only global variable dn_fib_info_cnt
> - dn_fib.c: remove the unused global function dn_fib_rt_message
> - dn_neigh.c: remove the unused global function dn_neigh_pointopoint_notify
> - dn_timer.c: remove the fast timer code that isn't used
> 
> Please review and comment on this patch.
> 

Looks fine to me. I'm quite happy to lose the fast ack code - unused code is
only a confusion to those reading it IMHO. If we do the delayed-ack code in
future then it's easy enough to reinstate.

Thanks.

-- 

patrick

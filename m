From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2.6.12-rc2 3/3] tg3: Fix tg3_restart_ints()
Date: Mon, 25 Apr 2005 14:56:25 -0700
Message-ID: <1114466185.4917.61.camel@rh4>
References: <1114463061.4917.34.camel@rh4>
 <1114463351.4917.39.camel@rh4> <1114464194.4917.52.camel@rh4>
 <20050425151816.1910b2ba.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akepner@sgi.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050425151816.1910b2ba.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-04-25 at 15:18 -0700, David S. Miller wrote:
> All 3 patches applied, looks great.
> 
> The only thing I see is that we might want to put a
> rmb() at the beginning of tg3_has_work() since we are
> clearing the status block bit right before we call it.
> It might not be necessary though.
> 

I think memory barriers are not needed since tg3_has_work() does not
depend on what's been written or read before it, other than sblk->status
which is a direct dependency.

From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 2/5] Bluetooth: Fix assignment of 0/1 to bool variables
Date: Sun, 22 Sep 2013 13:58:56 -0500
Message-ID: <B0200EA6-8CDA-41BE-9DD1-0A0E9CFDB2B5@holtmann.org>
References: <1379875453-20083-1-git-send-email-peter.senna@gmail.com> <1379875453-20083-2-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org, johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379875453-20083-2-git-send-email-peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Peter,

> Convert 0 to false and 1 to true when assigning values to bool
> variables. Inspired by commit 3db1cd5c05f35fb43eb134df6f321de4e63141f2.
> 
> The simplified semantic patch that find this problem is as
> follows (http://coccinelle.lip6.fr/):
> 
> @@
> bool b;
> @@
> (
> -b = 0
> +b = false
> |
> -b = 1
> +b = true
> )
> 
> Signed-off-by: Peter Senna Tschudin <peter.senna-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> 
> ---
> net/bluetooth/l2cap_core.c |   16 ++++++++--------
> 1 file changed, 8 insertions(+), 8 deletions(-)

Acked-by: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>

Regards

Marcel

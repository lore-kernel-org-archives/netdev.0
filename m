From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] bluetooth: scheduling while atomic bug fix
Date: Mon, 19 Oct 2009 19:37:11 -0700 (PDT)
Message-ID: <20091019.193711.147629067.davem@davemloft.net>
References: <20091019062441.GA4102@darkstar.vlan7>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091019062441.GA4102-4/PLUo9XfK+SVgrV+fD4Uw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 19 Oct 2009 14:24:41 +0800

> Due to driver core changes dev_set_drvdata will call kzalloc which should be
> in might_sleep context, but hci_conn_add will be called in atomic context
> 
> Like dev_set_name move dev_set_drvdata to work queue function.
> 
> oops as following:
 ...
> Signed-off-by: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied.

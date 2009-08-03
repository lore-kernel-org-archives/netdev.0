From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH]bluetooth: rfcomm_init bug fix
Date: Mon, 03 Aug 2009 13:29:24 -0700 (PDT)
Message-ID: <20090803.132924.151782729.davem@davemloft.net>
References: <20090803142616.GA1973@darkstar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org, alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090803142616.GA1973@darkstar>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 3 Aug 2009 22:26:16 +0800

> rfcomm tty may be used before rfcomm_tty_driver initilized,
> The problem is that now socket layer init before tty layer, if userspace
> program do socket callback right here then oops will happen.
> 
> reporting in:
> http://marc.info/?l=linux-bluetooth&m=124404919324542&w=2
 ...
> Reported-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Tested-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Signed-off-by: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied, thanks.

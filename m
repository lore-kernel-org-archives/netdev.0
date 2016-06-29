From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: wlcore: sdio: Fix crash on wlcore_probe_of when failing to
 parse/map irq
Date: Wed, 29 Jun 2016 15:46:23 +0000 (UTC)
Message-ID: <20160629154623.3A94D61367@smtp.codeaurora.org>
References: <1465519606-68129-1-git-send-email-bruherrera@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: poggi.raph-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bruno Herrera <bruherrera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465519606-68129-1-git-send-email-bruherrera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bruno Herrera <bruherrera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> pdev_data pointer is being freed with kfree but the pointer is not dynamic allocated.
> 
> Signed-off-by: Bruno Herrera <bruherrera-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

6edc119ed3b5 wlcore: sdio: Fix crash on wlcore_probe_of when failing to parse/map irq

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9168709/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

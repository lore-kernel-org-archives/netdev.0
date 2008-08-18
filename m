From: Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: ath5k text [Was: pull request: wireless-2.6 2008-08-17]
Date: Mon, 18 Aug 2008 09:00:34 +0200
Message-ID: <48A91E12.1060901@gmail.com>
References: <20080817185605.GC30679@tuxdriver.com> <20080817.151251.204370966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michael Karcher <kernel-53cgGKa3i4734X6bwOH/f4/+3M+ant7aZ+vKCSbpVNE@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080817.151251.204370966.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/18/2008 12:12 AM, David Miller wrote:
> Their commit messages reference SHA IDs but do not give a commit
> header line text reference as well.
> 
>       ath5k: Don't fiddle with MSI on suspend/resume.

John, this is it (even if I don't understand the purpose):

ath5k: Don't fiddle with MSI on suspend/resume.

Commit 256b152b005e319f985f50f2a910a75ba0def74f (ath5k: don't enable
MSI, we cannot handle it yet) has removed msi support, but overlooked
the suspend/resume code. This patch completes msi removal.

I don't consider this patch copyrightable, and thus put it into the
public domain. The result is of course a base.c file dual-licensed under
3-clause-BSD and GPL.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: add MSI interrupts support
Date: Mon, 24 Mar 2014 19:49:23 +0800
Message-ID: <20140324114923.GA3650@adam-laptop>
References: <1395640841-14477-1-git-send-email-adam.lee@canonical.com>
 <1395660884-15042-1-git-send-email-adam.lee@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1395660884-15042-1-git-send-email-adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 24, 2014 at 07:34:44PM +0800, Adam Lee wrote:
> Add MSI interrupts support, enable it when msi_support flag is true,
> also could fallback to pin-based interrupts mode if MSI mode fails.
> 
> Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
>  drivers/net/wireless/rtlwifi/pci.c | 63 ++++++++++++++++++++++++++++++++++++--
>  1 file changed, 61 insertions(+), 2 deletions(-)

This is the base of "[PATCH] rtlwifi: rtl8188ee: enable MSI interrupts
support" in thread. We met this issue[1] while enabling some HP
notebooks, whose wifi hardware modules can't get AP scan results with
pin-based interrupts.

Submitting these two patches ahead of RealTek's schedule so we can fix
it sooner for non-preload distro users.

[1] https://bugs.launchpad.net/bugs/1296591

-- 
Adam Lee
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

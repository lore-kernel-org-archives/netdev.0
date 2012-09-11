From: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: rtl8192ce: Log message that B_CUT device may
 not work
Date: Tue, 11 Sep 2012 19:23:27 +0200
Message-ID: <20120911192327.62fec16a@destiny.ordissimo>
References: <1347379873-9390-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Chaoming <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1347379873-9390-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Sep 2012 11:11:13 -0500, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote :

> There are a number of problems that occur for the latest version
> of the Realtek RTL8188CE device with the in-kernel driver. These
> include selection of the wrong firmware, and system lockup. A full
> fix is known, but is too invasive for inclusion in stable. This patch
> fixes the problem with loading the wrong firmware, and logs a message
> that the device may not work for kernels 3.6 and older.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
> Cc: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>
> Cc: Li Chaoming <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>

Tested-by: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>

Behaves as expected: I can see the warning then about 20 seconds later
the machine locks up.

Regards,

Anisse
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

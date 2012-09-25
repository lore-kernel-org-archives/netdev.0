From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH NEXT V3] rtlwifi: rtl8192c: rtl8192ce: Add support for
 B-CUT version of RTL8188CE
Date: Tue, 25 Sep 2012 15:57:31 -0400
Message-ID: <20120925195731.GE2118@tuxdriver.com>
References: <1347982168-10601-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>,
	Li Chaoming <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1347982168-10601-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2012 at 10:29:28AM -0500, Larry Finger wrote:
> Realtek devices with designation RTL8188CE-VL have the so-called B-cut
> of the wireless chip. This patch adds the special programming needed by
> these devices. In addition, a variable that was static has been moved into
> the private data area as it is now needed in two different routines. This
> change also fixes a minor bug that would be present if a system had more
> than one RTL81{88,92}CE devices. Other drivers in the rtlwifi family had
> already made this change, thus the variable already exists in the private
> data structure.
> 
> Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
> Cc: Anisse Astier <anisse-fwwRqrJYcP2HXe+LvDLADg@public.gmane.org>
> Cc: Li Chaoming <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
> ---
>  rtl8192c/phy_common.c |   21 +++++++++++++++++
>  rtl8192ce/def.h       |    3 ++
>  rtl8192ce/hw.c        |   60 +++++++++++++++++++++++++++++++++++++++++++++-----
>  rtl8192ce/phy.c       |    2 +
>  rtl8192ce/sw.c        |    6 +----
>  rtl8192ce/trx.c       |    4 +--
>  6 files changed, 85 insertions(+), 11 deletions(-)
> ---
> V1 => V2	Remove extraneous white space.
> V2 => V3	A change that is not part of the B-cut change and was introduced
> 		in V2 is moved to a separate patch. 

/home/linville/git/wireless-next
[linville-8530p.local]:> git am -s updates.mbox 
Applying: rtlwifi: rtl8192c: rtl8192ce: Add support for B-CUT version of RTL8188CE
error: patch failed: drivers/net/wireless/rtlwifi/rtl8192ce/def.h:116
error: drivers/net/wireless/rtlwifi/rtl8192ce/def.h: patch does not apply
error: patch failed: drivers/net/wireless/rtlwifi/rtl8192ce/hw.c:1004
error: drivers/net/wireless/rtlwifi/rtl8192ce/hw.c: patch does not apply
error: patch failed: drivers/net/wireless/rtlwifi/rtl8192ce/sw.c:162
error: drivers/net/wireless/rtlwifi/rtl8192ce/sw.c: patch does not apply
Patch failed at 0001 rtlwifi: rtl8192c: rtl8192ce: Add support for B-CUT version of RTL8188CE
The copy of the patch that failed is found in:
   /home/linville/git/wireless-next/.git/rebase-apply/patch
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

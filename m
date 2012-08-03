From: Joseph Salisbury <joseph.salisbury-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [REGRESSION][v3.5] iwlwifi: include rssi as part of decision making
 for reduce txpower
Date: Fri, 03 Aug 2012 12:24:09 -0400
Message-ID: <501BFB29.7010801@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello,

A bug[0] was reported against Ubuntu that reports a kernel panic when 
using the hotkey to disable then re-enable wifi on a Dell XPS 14z.  A 
kernel bisect was performed, which indicated the following commit as the 
source of the regression:


commit dd551ab7b47ace14753b0d73f79437cc35adcf6b
Author: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date:   Thu May 3 14:22:01 2012 -0700

     iwlwifi: include rssi as part of decision making for reduce txpower

     In bt coex, consider the average rssi as part of decision making 
process

     Change-Id: I8d11d7f177a6875e2a9d08f7539d42253226fd7a
     Signed-off-by: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
     Reviewed-on: http://git-mwg.jer.intel.com/gerrit/1945
     Tested-by: Jenkins
     Reviewed-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
     Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

A test kernel was created with this commit reverted, which stopped the 
kernel panic from occurring.

A bugzilla bug[1] has been opened.

Thanks,

Joe


[0] https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1029547
[1] https://bugzilla.kernel.org/show_bug.cgi?id=45491
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: fix iwlwifi scanning corner cases
Date: Wed, 6 Oct 2010 11:02:35 +0200
Message-ID: <20101006090228.GA2523@redhat.com>
References: <20101005085717.GA18012@redhat.com>
 <1286317292-10679-1-git-send-email-florian@mickler.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ben.m.cahill-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1286317292-10679-1-git-send-email-florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Florian

On Wed, Oct 06, 2010 at 12:21:32AM +0200, Florian Mickler wrote:
> Stanislaw Gruszka pointed out, that commit
> "iwl3945: queue the right work if the scan needs to be aborted"
> has an awkward definition of "right". Specifically the abort_scan work
> doesn't notify the generic wireless stack that the scan was aborted.
> 
> In order to get rid of the warning in bug
> https://bugzilla.kernel.org/show_bug.cgi?id=17722
> we inform ieee80211_scan_completed that we are aborting
> the scan by setting the apropriate status bit in request_scan and 
> pass it into ieee80211_scan_completed. 
> 
> Signed-off-by: Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>
> ---
> 
> Hi John!
> 
> Here is the fix that Stanislaw described. 
> (Yes, it is in a brown paper bag.)  Please wait for him to review this. 
> 
> Another option would be to just revert my previous patch and live with the 
> warning until the scanning rework hit's mainline.

This patch is not so bad, but better would be just return value from 
{iwlagn,iwl3945}_request_scan instead of queuing anything. I will
prepare patch(s) today or tomorrow.

Stanislaw
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

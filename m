From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v3 1/3] iwlwifi: mvm: add real TSO implementation
Date: Thu, 20 Aug 2015 06:12:43 -0700
Message-ID: <1440076363.6610.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440058544-20342-1-git-send-email-emmanuel.grumbach@intel.com>
	 <1440058544-20342-2-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1440058544-20342-2-git-send-email-emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-08-20 at 11:15 +0300, Emmanuel Grumbach wrote:
> The segmentation is done completely in software. The
> driver creates several MPDUs out of a single large send.
> Each MPDU is a newly allocated SKB.
> A page is allocated to create the headers that need to be
> duplicated (SNAP / IP / TCP). The WiFi header is in the
> header of the newly created SKBs.
> 
> type=feature
> 
> Change-Id: I238ffa79cacc5bbdacdfbf3e9673c8d4f02b462a
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wireless/iwlwifi/mvm/tx.c | 513 +++++++++++++++++++++++++++++++---
>  1 file changed, 481 insertions(+), 32 deletions(-)


Ouch again.

This will be a NACK. Sorry.


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: James Ketrenos <jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [ANNOUNCE] d80211 based driver for Intel PRO/Wireless 3945ABG
Date: Fri, 09 Feb 2007 13:52:32 -0800
Message-ID: <45CCED20.90403@linux.intel.com>
References: <45CCE3CA.4050904@linux.intel.com> <17868.62734.497825.667962@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <17868.62734.497825.667962-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Neil Brown wrote:
> On Friday February 9, jketreno-VuQAYsv1563Yd54FQh9/CA@public.gmane.org wrote:
>> Ok.  Now... any questions?
> 
> Yes.  Does this require a closed user-space helper like the other
> 3945ABG driver, or is it completely open (maybe excepting firmware)?

The iwlwifi driver for the 3945 does not require the user space daemon, 
but does require a new microcode image.

Over the past year we were able to make the necessary changes to the 
microcode used with the 3945 such that we were able to remove the 
regulatory daemon.

James
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

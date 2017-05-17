From: Oliver Neukum <oneukum-IBi9RG/b67k@public.gmane.org>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Wed, 17 May 2017 09:44:20 +0200
Message-ID: <1495007060.30577.8.camel@suse.com>
References: <1494956480-6127-1-git-send-email-jim_baxter@mentor.com>
         <1494956480-6127-2-git-send-email-jim_baxter@mentor.com>
         <87shk4fynp.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
        Jim Baxter <jim_baxter-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87shk4fynp.fsf-3F4PFWf5pNjpjLOzFPqGjWGXanvQGlWp@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 16.05.2017, 20:24 +0200 schrieb Bjørn Mork:
> 
> I must say that I don't like the additional complexity added here.  If
> there are memory issues and you can reduce the buffer size to
> USB_CDC_NCM_NTB_MIN_OUT_SIZE, then why don't you just set a lower tx_max
> buffer size in the first place?
> 
>   echo 2048 > /sys/class/net/wwan0/cdc_ncm/tx_max
> 

Hi,

that would hurt performance across the board though.
Can we trigger memory compactation earlier?

	Regards
		Oliver

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

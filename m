From: "Franky Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 5/7]
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c: adjust suspicious bit
 operation
Date: Wed, 6 Jun 2012 16:43:10 -0700
Message-ID: <4FCFEB0E.2020206@broadcom.com>
References: <1339018901-28439-1-git-send-email-Julia.Lawall@lip6.fr>
 <1339018901-28439-6-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brett Rudley" <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Roland Vossen" <rvossen-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Arend van Spriel" <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Kan Yan" <kanyan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	"Julia Lawall" <julia-dAYI7NvHqcQ@public.gmane.org>
To: "Julia Lawall" <Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339018901-28439-6-git-send-email-Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/06/2012 02:41 PM, Julia Lawall wrote:
> From: Julia Lawall<Julia.Lawall-L2FTfq7BK8M@public.gmane.org>
>
> IRQF_TRIGGER_HIGH is 0x00000004, so it seems that&  was intended rather than |.
>
> This problem was found using Coccinelle (http://coccinelle.lip6.fr/).
>
> Signed-off-by: Julia Lawall<julia-dAYI7NvHqcQ@public.gmane.org>

Thanks, Julia. But this has already been fixed by Joe Perches [1] and 
the patch has arrived at Linux wireless tree.

Franky

[1] https://lkml.org/lkml/2012/5/30/482

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

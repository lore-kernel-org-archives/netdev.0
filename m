From: Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 0/3] hostap: Fine-tuning for a few functions
Date: Sat, 20 Aug 2016 21:26:42 +0200
Message-ID: <3b3c91ad-3225-3483-bb58-fdee33bf2290@broadcom.com>
References: <566ABCD9.1060404@users.sourceforge.net>
 <f0cd7a82-e603-6a91-0afd-33bbd1658cab@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: SF Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Jouni Malinen <j@w1.fi>, Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <f0cd7a82-e603-6a91-0afd-33bbd1658cab-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 20-08-16 18:43, SF Markus Elfring wrote:
> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Date: Sat, 20 Aug 2016 18:35:43 +0200
> 
> A few update suggestions were taken into account
> from static source code analysis.

Is it worth touching this old stuff especially when you are not making
any functional changes.

Regards,
Arend

> Markus Elfring (3):
>   Use memdup_user()
>   Delete an unnecessary jump label
>   Delete unnecessary variable initialisations
> 
>  .../net/wireless/intersil/hostap/hostap_ioctl.c    | 36 ++++++++--------------
>  1 file changed, 12 insertions(+), 24 deletions(-)
> 

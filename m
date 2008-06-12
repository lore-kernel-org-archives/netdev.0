From: "Pekka Enberg" <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Subject: Re: [PATCH] ssb: Fix coherent DMA mask for PCI devices
Date: Fri, 13 Jun 2008 00:44:13 +0300
Message-ID: <84144f020806121444i43d381ehdee1774c135d8841@mail.gmail.com>
References: <200806121533.14435.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>,
	"Glauber Costa" <gcosta-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: "Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200806121533.14435.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 12, 2008 at 4:33 PM, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> This fixes setting the coherent DMA mask for PCI devices.
>
> Signed-off-by: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
>
> ---
>
> John, please queue this bugfix for 2.6.26
>
> The whole SSB DMA API should be rewritten, as it makes too many bad
> assumptions about the other subsytems. I will do that soon.
> But let's apply this patch for now, as it fixes this particular bug.

Hmm. Does the patch have anything to do with this bug report?

http://bugzilla.kernel.org/show_bug.cgi?id=10819
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] adm8211: fix checkpatch error for trailing statements
 on next line
Date: Tue, 5 May 2015 06:19:38 +0100
Message-ID: <20150505051827.GA2463@bytefire-computer>
References: <20150503104231.GA3607@bytefire-computer>
 <87lhh4wm3n.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87lhh4wm3n.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 04, 2015 at 03:42:04PM +0300, Kalle Valo wrote:
> Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> 
> > This patch fixes the checkpatch.pl error:
> >
> > ERROR: trailing statements should be on next line
> >
> > More specifically, the fix has been applied to the four occurances of the error listed below.
> >
> > ERROR: trailing statements should be on next line
> > #1101: FILE: drivers/net/wireless/adm8211.c:1101:
> > +               case  0x8: reg |= (0x1 << 14);
> >
> > ERROR: trailing statements should be on next line
> > #1103: FILE: drivers/net/wireless/adm8211.c:1103:
> > +               case 0x16: reg |= (0x2 << 14);
> >
> > ERROR: trailing statements should be on next line
> > #1105: FILE: drivers/net/wireless/adm8211.c:1105:
> > +               case 0x32: reg |= (0x3 << 14);
> >
> > ERROR: trailing statements should be on next line
> > #1107: FILE: drivers/net/wireless/adm8211.c:1107:
> > +                 default: reg |= (0x0 << 14);
> >
> > Signed-off-by: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > ---
> >  drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
> >  1 file changed, 12 insertions(+), 8 deletions(-)
> 
> The patch has incorrectly "staging:" prefix in the title, please fix
> that. "adm8211:" is enough, you don't need anything for drivers in
> drivers/net/wireless.
> 
> -- 
> Kalle Valo

Thanks Kalle for clarifying. I have removed "staging:" prefix and pasted the patch below.

Signed-off-by: Okash Khawaja <okash.khawaja-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/adm8211.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index f07a618..79e4e5f 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
                pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
 
                switch (cline) {
-               case  0x8: reg |= (0x1 << 14);
-                          break;
-               case 0x16: reg |= (0x2 << 14);
-                          break;
-               case 0x32: reg |= (0x3 << 14);
-                          break;
-                 default: reg |= (0x0 << 14);
-                          break;
+               case  0x8:
+                       reg |= (0x1 << 14);
+                       break;
+               case 0x16:
+                       reg |= (0x2 << 14);
+                       break;
+               case 0x32:
+                       reg |= (0x3 << 14);
+                       break;
+                 default:
+                       reg |= (0x0 << 14);
+                       break;
                }
        }
 
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

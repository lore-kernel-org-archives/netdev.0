From: Okash Khawaja <okash.khawaja@gmail.com>
Subject: Re: [PATCH v3] adm8211: fix checkpatch error for trailing statements
 on next line
Date: Tue, 5 May 2015 12:45:17 +0100
Message-ID: <20150505114517.GA2934@bytefire-computer>
References: <20150505060150.GA2548@bytefire-computer>
 <1430808298.7191.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:35008 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031623AbbEELpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 07:45:22 -0400
Content-Disposition: inline
In-Reply-To: <1430808298.7191.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 04, 2015 at 11:44:58PM -0700, Joe Perches wrote:
> On Tue, 2015-05-05 at 07:01 +0100, Okash Khawaja wrote:
> > This patch fixes the checkpatch.pl error:
> 
> Please fix the space/tab use too.
> 
> Your email client seems to have converted all the tabs
> to spaces.
> 
> default should use the same indent as the case statements
>

Joe and Kalle,

I have adjusted the patch. Since indentation of default adds more to the
patch I have resent it under the subject '[PATCH] adm8211: fix
checkpatch errors for indentation and new line around switch-case'.
Thanks for the prompt feedback. I appreciate your patience.

> 
> > diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
> []
> > @@ -1098,14 +1098,18 @@ static void adm8211_hw_init(struct ieee80211_hw *dev)
> >                 pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
> >  
> >                 switch (cline) {
> > -               case  0x8: reg |= (0x1 << 14);
> > -                          break;
> > -               case 0x16: reg |= (0x2 << 14);
> > -                          break;
> > -               case 0x32: reg |= (0x3 << 14);
> > -                          break;
> > -                 default: reg |= (0x0 << 14);
> > -                          break;
> > +               case  0x8:
> > +                       reg |= (0x1 << 14);
> > +                       break;
> > +               case 0x16:
> > +                       reg |= (0x2 << 14);
> > +                       break;
> > +               case 0x32:
> > +                       reg |= (0x3 << 14);
> > +                       break;
> > +                 default:
> > +                       reg |= (0x0 << 14);
> > +                       break;
> >                 }
> >         }
> >  
> 

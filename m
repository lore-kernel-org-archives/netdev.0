From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH v2] net/r8169: update the new parser for the new firmware
Date: Fri, 17 Jun 2011 11:25:13 +0800
Message-ID: <8AC7DE11560749B895F99EBA7D42AA49@realtek.com.tw>
References: <1308109531-31698-1-git-send-email-hayeswang@realtek.com> <20110616225904.GA2064@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:50954 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab1FQDZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:25:21 -0400
In-Reply-To: <20110616225904.GA2064@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Friday, June 17, 2011 6:59 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH v2] net/r8169: update the new parser for 
> the new firmware
> 
> Hayes Wang <hayeswang@realtek.com> :
> > Update the parser for the new firmware which is embedded 
> some information.
> 
> I have modified several things :
> - s/u32/__le32/ in fw_info
> - fix unsigned (size_t) comparisons
> - more size checks before dereferencing fw_info
> 

Thanks. They are fine.

> The new firmware format should be the same. The old 
> r8168d-1.fw firmware proved usable when prefixed with :
> 
> 0000000: 0000 0000 3031 0000 0000 0000 0000 0000  ....01..........
> 0000010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> 0000020: 0000 0000 3000 0000 7501 0000 a000 0000  ....0...u.......
> 
> I realized after testing that netif_err could be abused with 
> non-string fw_info.version. :o/
> 

Excuse me. I don't understand what you want to express. Do you mean the
situation of the old paser with the new firmware for checking the firmware? For
the normal situation, the old paser would not use the new firmware. And I put
zero in front of the new firmware to prevent the old paser from running it. That
is all I do.

If you don't mean that, I could promise the new firmware I release would contain
the valid string unless someone modifies it.

> Comments ?
> 
 
Best Regards,
Hayes


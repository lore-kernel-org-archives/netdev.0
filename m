From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] net/r8169: update the new parser for the new
 firmware
Date: Fri, 17 Jun 2011 13:22:44 +0100
Message-ID: <1308313364.11457.63.camel@localhost>
References: <1308109531-31698-1-git-send-email-hayeswang@realtek.com>
	 <20110616225904.GA2064@electric-eye.fr.zoreil.com>
	 <8AC7DE11560749B895F99EBA7D42AA49@realtek.com.tw>
	 <20110617063948.GA2146@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: hayeswang <hayeswang@realtek.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110617063948.GA2146@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-06-17 at 08:39 +0200, Francois Romieu wrote:
> hayeswang <hayeswang@realtek.com> :
> > Francois Romieu :
> [...]
> > > The new firmware format should be the same. The old 
> > > r8168d-1.fw firmware proved usable when prefixed with :
> > > 
> > > 0000000: 0000 0000 3031 0000 0000 0000 0000 0000  ....01..........
> > > 0000010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
> > > 0000020: 0000 0000 3000 0000 7501 0000 a000 0000  ....0...u.......
> > > 
> > > I realized after testing that netif_err could be abused with 
> > > non-string fw_info.version. :o/
> > > 
> > 
> > Excuse me. I don't understand what you want to express. Do you mean the
> > situation of the old paser with the new firmware for checking the firmware?
> 
> No. The code does a printk with a %s specifier on fw_info.version while there
> is no evidence that fw_info.version is 0 terminated.

I thought the idea of embedding a version here was to be able to report
in in get_drvinfo, not to print it on load.

Ben.

> > For the normal situation, the old paser would not use the new firmware.
> > And I put zero in front of the new firmware to prevent the old paser from
> > running it. That is all I do.
> 
> It is fine.
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

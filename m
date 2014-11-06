From: Charles Keepax <ckeepax@opensource.wolfsonmicro.com>
Subject: Re: "asix: Don't reset PHY on if_up for ASIX 88772" breaks net on
	arndale platform
Date: Thu, 6 Nov 2014 12:46:53 +0000
Message-ID: <20141106124653.GV23178@opensource.wolfsonmicro.com>
References: <C89EFD3CD56F64468D3D206D683A8D2203985F49@ldam-msx2.fugro-nl.local> <20141104094336.GA3145@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D2203985FA9@ldam-msx2.fugro-nl.local> <20141104200914.GN23178@opensource.wolfsonmicro.com> <C89EFD3CD56F64468D3D206D683A8D22039FFC5F@ldam-msx2.fugro-nl.local> <20141105150258.GR23178@opensource.wolfsonmicro.com> <20141106090651.GA19109@afflict.kos.to> <20141106100104.GS23178@opensource.wolfsonmicro.com> <20141106120416.GA20162@afflict.kos.to> <C89EFD3CD56F64468D3D206D683A8D22039FFE16@ldam-msx2.fugro-nl.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Riku Voipio <riku.voipio@iki.fi>, freddy@asix.com.tw,
	davem@davemloft.net, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-samsung-soc@vger.kernel.org
To: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C89EFD3CD56F64468D3D206D683A8D22039FFE16@ldam-msx2.fugro-nl.local>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 06, 2014 at 01:39:07PM +0100, Stam, Michel [FINT] wrote:
> Hello Riku and Charles,
> 
> I tried this with my original patch and the suggested patch applied,
> this seems to work for me too.
> 
> One thing that bothers me, is the suspend / resume situation; usbnet.c
> seems to call the bind( ) on probe( ). Suspend / resume do not seem to
> call bind( ) directly.
> 
> As Riku pointed out, the original patch I reverted was because of
> suspend/resume issues. I wonder if this will still work? 

I seem to remember I had a few issues with Arndale suspend and
resume last time I tried it anyways, so not sure I will be able
to test for that. But I will have a go. But in either case I
guess a fix for that is probably orthogonal to my suggested fix
here, as it looks pretty clear we intended to fully reset the
device in bind and were appartently not doing that. So this
patch is probably a needed fix anyway. Even if there are
seperate issues relating to suspend and resume.

Thanks,
Charles

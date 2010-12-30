From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [uClinux-dev] Re: dm9000 patch
Date: Thu, 30 Dec 2010 17:12:33 +0200
Message-ID: <20101230151233.GD11160@jasper.tkos.co.il>
References: <4D1A5C2A.5050606@gmail.com>
 <20101229060637.GA31010@jasper.tkos.co.il>
 <4D1B33F2.5060600@gmail.com>
 <20101229180650.GE6067@tarshish>
 <AANLkTim0+GbddLdkPFoggeCKpU7on7mta0V2mZZLgviE@mail.gmail.com>
 <4D1BA0D0.1060407@gmail.com>
 <4D1BD461.4070104@snapgear.com>
 <4D1C5807.5050702@gmail.com>
 <4D1C6A30.6020706@snapgear.com>
 <4D1C9FA5.6040208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Ungerer <gerg@snapgear.com>,
	uClinux development list <uclinux-dev@uclinux.org>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-m68k@vger.kernel.org
To: Angelo Dureghello <angelo70@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D1C9FA5.6040208@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Angelo,

On Thu, Dec 30, 2010 at 04:05:09PM +0100, Angelo Dureghello wrote:
> Hi Greg and All,
> infinite thanks, i solved finally my issue and the board is fully working.
> 
> I used IRQ7 line, casually, and unfortunately it was wrong.
> IRQ7 is a special autovectored interrupt, in particular, it is an
> EDGE interrupt, and not a LEVEL interrupt like IRQ1 to 6.
> 
> I used IRQ1 now, a normal level interrupt, and everything works perfect.
> 
> So i have dm9000 and MCF5307 (big-endian cpu) fully working with 32
> bit bus straight wired D0:31 to the dm9000, and would like to share
> my patch to dm9000.c, so maybe in next kernel versions dm9000 maybe
> could be enabled as default. Let me know eventually the procedure
> for this.

Just send the patch to the netdev mailing list. For additional instructions 
see Documentation/SubmitChecklist and Documentation/SubmittingPatches. Once 
you submitted you patch you can track the status of your patch at 
http://patchwork.ozlabs.org/project/netdev/list/.

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -

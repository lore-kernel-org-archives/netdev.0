From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
Date: Tue, 30 Nov 2010 14:37:18 +0800
Message-ID: <D55F10610749464CA0876CBA5325BB69@realtek.com.tw>
References: <1290772470-23713-1-git-send-email-hayeswang@realtek.com>     <1290779458.3051.45.camel@localhost>     <20101126224914.GA12266@electric-eye.fr.zoreil.com>     <1290813146.3051.58.camel@localhost>     <CE0F8B12F31D4E82860F4CE06907E98B@realtek.com.tw>     <20101129233334.GA2888@electric-eye.fr.zoreil.com> <20101129161344.059239d6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Ben Hutchings' <benh@debian.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>, <564628@bugs.debian.org>
To: 'Stephen Hemminger' <shemminger@vyatta.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101129161344.059239d6@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Romieu,

Let me explain that not all of the phy settings are the ram code (or firmware).
Some of them are the initialization sequence. Only the "Low pass filter &
DLY_CAP fine tune from uC" is the firmware. And there is no firmware before
RTL8111D. That is, except 8111DP, the chips which have firmware are 8111d,
8111e,and 8105 now.

Now, I would modify my patch according to the example from Ben. And I would
update the firmware and licence to linux-firmware.

Thanks for everybody who help and answer to me.
 
Best Regards,
Hayes


> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
> Sent: Tuesday, November 30, 2010 8:14 AM
> To: Francois Romieu
> Cc: Hayeswang; 'Ben Hutchings'; netdev@vger.kernel.org; 
> linux-kernel@vger.kernel.org; 'David Miller'; 564628@bugs.debian.org
> Subject: Re: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
> 
> On Tue, 30 Nov 2010 00:33:34 +0100
> Francois Romieu <romieu@fr.zoreil.com> wrote:
> 
> > hayeswang <hayeswang@realtek.com> :
> > > Excuse me, I have some questions about the firmware patch.
> > > 
> > > 1. I should convert the data into the binary files 
> (.bin). Is it right?
> > 
> > You may do it.
> > 
> > Fwiw I have cooked something for it in the attached patch 
> #9 this WE. 
> > Feel free to take bits from it. I will not do more changes 
> while you work on it.
> > 
> > > 2. Where should I update the firmware files? Is the path the 
> > > linux-2.6/firmware?
> > 
> > ! This directory is only here to contain firmware images extracted 
> > from old ! device drivers which predate the common use of 
> request_firmware().
> > 
> > It is fine for the existing code.
> > 
> > > However, according to 
> linux-2.6/firmeware/README.AddingFirmware, I 
> > > should update they to another repository:
> > > 	
> > > 
> git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.g
> > > it
> > 
> > /me scratches head.
> > 
> > Assuming Realtek does not intend to stand this code / data 
> as GPLable, yes.
> > It will help people staying clear from non-free code, it will help 
> > packaging something useful and it will remove some cruft 
> from the code.
> > 
> > So everybody will end happy. Especially after an aspirin.
> 
> The plan is to do away with linux-2.6/firmware entirely.
> Distributions are shipping the firmware from linux-firmware, 
> not the kernel files.
> 
> 
> ------Please consider the environment before printing this e-mail. 
> 
> 

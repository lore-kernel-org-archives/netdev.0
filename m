From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
Date: Mon, 29 Nov 2010 11:47:07 +0800
Message-ID: <CE0F8B12F31D4E82860F4CE06907E98B@realtek.com.tw>
References: <1290772470-23713-1-git-send-email-hayeswang@realtek.com> <1290779458.3051.45.camel@localhost> <20101126224914.GA12266@electric-eye.fr.zoreil.com> <1290813146.3051.58.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	'David Miller' <davem@davemloft.net>, <564628@bugs.debian.org>
To: 'Ben Hutchings' <benh@debian.org>,
	'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1290813146.3051.58.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Excuse me, I have some questions about the firmware patch.

1. I should convert the data into the binary files (.bin). Is it right?

2. Where should I update the firmware files? Is the path the
linux-2.6/firmeware?
    However, according to linux-2.6/firmeware/README.AddingFirmware, I
should
    update they to another repository:

	
git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git

    Then, how the firmware merge with kernel-2.6? Or, where could I find the
firmware
    in the kernel-2.6 repository?
 
Best Regards,
Hayes


> -----Original Message-----
> From: Ben Hutchings [mailto:benh@debian.org] 
> Sent: Saturday, November 27, 2010 7:12 AM
> To: Francois Romieu; Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; 
> David Miller; 564628@bugs.debian.org
> Subject: Re: [PATCH] net/r8169: Correct the ram code for RTL8111D(L)
> 
> On Fri, 2010-11-26 at 23:49 +0100, Francois Romieu wrote:
> > Ben Hutchings <benh@debian.org> :
> > > On Fri, 2010-11-26 at 19:54 +0800, Hayes Wang wrote:
> > > > Correct the binary code (Low pass filter & DLY_CAP fine 
> tune from uC).
> > > > The incorrect ram code would make the nic working abnormally.
> > > [...]
> > > 
> > > I'm glad you finally acknowledge that this is code rather than 
> > > simple register initialisation.
> > 
> > I am not sure that Hayes is a native english speaker.
> > 
> > I am glad to see him posting here.
> 
> Right.
> 
> Hayes, by 'you' I meant Realtek, not you personally.  If my 
> reply seemed aggressive, I apologise.
> 
> > [...]
> > > Below are the changes Debian currently applies in preparation for 
> > > proper licencing of the firmware.
> > 
> > Do you have some scripts to convert the data at hand ?
> [...]
> 
> No, it's easy enough to convert a single array by copying it 
> into a C file that dumps it to stdout (assuming the file's 
> byte order is defined to match your own machine).
> 
> It might be worth adding some sort of header with a version 
> and checksum.  Your choice, really.
> 
> Ben.
> 
> --
> Ben Hutchings, Debian Developer and kernel team member
> 
> 

From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 1/2] r8169: enable ALDPS for power saving
Date: Wed, 24 Oct 2012 22:05:25 +0200
Message-ID: <20121024200525.GB6347@electric-eye.fr.zoreil.com>
References: <1350893153-18320-1-git-send-email-hayeswang@realtek.com> <20121022192748.GA16370@electric-eye.fr.zoreil.com> <D81B36B929404E28AE7007B7E21B9D46@realtek.com.tw> <20121023193146.GA10463@electric-eye.fr.zoreil.com> <B3B61E0990514F28A8203537EB9D047A@realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: hayeswang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B3B61E0990514F28A8203537EB9D047A@realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hayeswang <hayeswang@realtek.com> :
>  Francois Romieu [mailto:romieu@fr.zoreil.com] 
> [...]
> > It would be nice to state these things in the commit message, namely:
> > - ALDPS should never be enabled for the RTL8105e
> > - none of the firmware-free chipsets support ALDPS
> > - neither do the RTL8168d/8111d
> 
> Excuse me. I don't understand why the RTL8105e shouldn't enable ALDPS.

I'd appreciate to see such a statement if ALDPS can be enabled with the
RTL8105e !

You have sent ALDPS related patches for some specific chipsets. Now
would be a sensible time to check if ALDPS is correctly handled for
_all_ supported chipsets. I don't have access to your authoritative
resources. I can only outline something strange in the code wrt
ALDPS and the 8105e.

/me returns to 8169b RxOverflow oddities...

-- 
Ueimor

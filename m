From: hayeswang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/7] r8169: Update PHY settings of RTL8111G
Date: Tue, 2 Apr 2013 10:19:17 +0800
Message-ID: <2CDCEE66B3D64940AB7259FBACFFDC6F@realtek.com.tw>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com> <1364824539-4156-2-git-send-email-hayeswang@realtek.com> <20130401222048.GA19335@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130401222048.GA19335@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, April 02, 2013 6:21 AM
> To: Hayeswang
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: Re: [PATCH net-next 2/7] r8169: Update PHY settings 
> of RTL8111G
> 
> Hayes Wang <hayeswang@realtek.com> :
> > - Replace the current settings with rtl_writephy and rtl_readphy.
> >   For the hardware, the settings are same with previous ones. This
> >   make the setting method like the previous chips.
> > - Add new PHY settings.
> 
> Would you mind spliting it in two ?

OK.

[...]
> > -	if (r8168_phy_ocp_read(tp, 0xa466) & 0x0100)
> > -		rtl_w1w0_phy_ocp(tp, 0xc41a, 0x0002, 0x0000);
> > -	else
> > -		rtl_w1w0_phy_ocp(tp, 0xbcc4, 0x0000, 0x0002);
>                                      ^^^^^^
> This one was not right, was it ?

No, it was not right. It seems a mistake for copying and pasting.

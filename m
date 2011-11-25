From: Jonathan Nieder <jrnieder@gmail.com>
Subject: Re: [bug?] r8169: hangs under heavy load
Date: Fri, 25 Nov 2011 14:54:51 -0600
Message-ID: <20111125205451.GG26692@elie.hsd1.il.comcast.net>
References: <4E7F4D45.7040902@wolke7.net>
 <1316978632.4122.103.camel@deadeye>
 <4E82C0B5.1050902@wolke7.net>
 <1317254171.4068.12.camel@deadeye>
 <20111124044137.GA18262@elie.hsd1.il.comcast.net>
 <4ECFE7A7.5070300@wolke7.net>
 <20111125201936.GA26692@elie.hsd1.il.comcast.net>
 <1322253122.2550.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Francois Romieu <romieu@fr.zoreil.com>,
	linux-kernel@vger.kernel.org,
	Armin Kazmi <armin.kazmi@tu-dortmund.de>,
	Gerd <booster@wolke7.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1322253122.2550.3.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:

> rtl8169_rx_interrupt(..., budget) can return budget + 1 sometimes
> because of :
>
>                 /* Work around for AMD plateform. */
>                 if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
>                     (tp->mac_version == RTL_GIGA_MAC_VER_05)) {
>                         desc->opts2 = 0;
>                         cur_rx++;
>                 }
>
> Sorry, I wont patch this today, its black Friday, and David said to
> patch submitters :
>
> "stick to turkey and wine you're better at it" 

:)  Sensible enough.  Thanks for the quick response!

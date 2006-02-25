From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 16:47:40 -0600
Message-ID: <4400DE8C.1000303@lwfinger.net>
References: <43FF88E6.6020603@linux.intel.com>	<20060225084139.GB22109@infradead.org>	<200602250549.47547.gene.heskett@verizon.net>	<Pine.LNX.4.61.0602251518200.31692@yvahk01.tjqt.qr>	<pan.2006.02.25.22.07.53.810642@free.fr> <17408.55266.948833.168988@smtp.charter.net> <4400DA0B.1060502@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Stoffel <john@stoffel.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932202AbWBYWrt@vger.kernel.org>
To: matthieu castet <castet.matthieu@free.fr>
In-Reply-To: <4400DA0B.1060502@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

matthieu castet wrote:
> And what happen with the userspace binary blob ?
> 
> How it will know in which country you are ?
> Does it access to a secret GPS on your computer ?
> 
> So there are 2 solutions :
> - make the card work only for a country with a flag in a RO eeprom or in 
> another place in the hardware (firmware, ....).
> - make the card works on all the possible channels.
> 
> Also if the firmware need to be load each time you reset the card (this 
> is the case with the current ipw2xxx implementation), you won't notice 
> if you switch for a firmware for a country X to a firmware for a country Y.

I haven't looked at the driver code, but I would expect it to be like the ipw2200 where the 
"country" code is in eeprom, which sets a code specifying the region where it will work. If you take 
a given piece of hardware somewhere else in the world, it will likely not be in complience.

Larry

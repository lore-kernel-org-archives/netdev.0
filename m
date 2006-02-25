From: matthieu castet <castet.matthieu@free.fr>
Subject: Re: [Announce] Intel PRO/Wireless 3945ABG Network Connection
Date: Sat, 25 Feb 2006 23:28:27 +0100
Message-ID: <4400DA0B.1060502@free.fr>
References: <43FF88E6.6020603@linux.intel.com>	<20060225084139.GB22109@infradead.org>	<200602250549.47547.gene.heskett@verizon.net>	<Pine.LNX.4.61.0602251518200.31692@yvahk01.tjqt.qr>	<pan.2006.02.25.22.07.53.810642@free.fr> <17408.55266.948833.168988@smtp.charter.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932134AbWBYW2h@vger.kernel.org>
To: John Stoffel <john@stoffel.org>
In-Reply-To: <17408.55266.948833.168988@smtp.charter.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

John Stoffel wrote:
>>>>>>"Matthieu" == Matthieu CASTET <castet.matthieu@free.fr> writes:
> 
> 
> Matthieu> I will say, why not put the restriction of the firmware
> Matthieu> binary blob ?  It run on the device so it will be difficult
> Matthieu> for people to analyse it.
> 
> So what do I do when I take my US laptop and fly to country X, which
> has comletely different rules for these radios?  Do I have to re-flash
> my firmware to make it work properly?  
> 
And what happen with the userspace binary blob ?

How it will know in which country you are ?
Does it access to a secret GPS on your computer ?

So there are 2 solutions :
- make the card work only for a country with a flag in a RO eeprom or in 
another place in the hardware (firmware, ....).
- make the card works on all the possible channels.

Also if the firmware need to be load each time you reset the card (this 
is the case with the current ipw2xxx implementation), you won't notice 
if you switch for a firmware for a country X to a firmware for a country Y.

Matthieu

From: "Jory A. Pratt" <anarchy@nctv.com>
Subject: Re: bcm43xx scan oops!!!
Date: Tue, 10 Oct 2006 16:44:43 -0500
Message-ID: <452C144B.9040006@nctv.com>
References: <452B1015.6040104@nctv.com> <200610101217.55909.mb@bu3sch.de> <452BACF2.60900@nctv.com> <200610102306.16143.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxo4.broadbandsupport.net ([209.55.3.84]:6113 "EHLO
	mxo4.broadbandsupport.net") by vger.kernel.org with ESMTP
	id S1030500AbWJJVpA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 17:45:00 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200610102306.16143.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 10 October 2006 16:23, Jory A. Pratt wrote:
>   
>> Michael Buesch wrote:
>>     
>>> On Tuesday 10 October 2006 05:14, Jory A. Pratt wrote:
>>>   
>>>       
>>>> http://home.nctv.com/anarchy/dscape-clean.jpg
>>>>     
>>>>         
>>> That's hardly readable.
>>> But which firmware are you running? v4.x by chance?
>>>
>>>   
>>>       
>> Just for completeness I just tested with v4.x firmware and still get the 
>> panic
>>     
>
> 4.x firmware won't work. Make sure to use 3.x.
>
> I am not sure what happens.
> Any chance to get a more complete oops message? I am also interrested
> in the start of the oops message. In particular I would like to see if this
> is a NULL pointer bug, machine check or something else.
> The backtrace is a little big weird. So I am not sure what happens.
>
> And, Please make _really_ sure to use 3.x firmware. ;)
>
>   
alright here are two more pics for you.

http://home.nctv.com/anarchy/dscape-clean1.jpg
http://home.nctv.com/anarchy/dscape-clean2.jpg


Here is a bit of dmesg that you might find useful:

ssb: Core 0 found: cc 0800, rev 0D, vendor 4243
ssb: Core 1 found: cc 0812, rev 09, vendor 4243
ssb: Core 2 found: cc 0804, rev 0C, vendor 4243
ssb: Core 3 found: cc 080D, rev 07, vendor 4243
bcm43xx_d80211: Broadcom 4318 WLAN found
ssb: Switching to core 2
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: Detected PHY: Version: 3, Type 2, Revision 7
bcm43xx_d80211: Detected Radio: ID: 8205017f (Manuf: 17f Ver: 2050 Rev: 8)
bcm43xx_d80211: Radio turned off
bcm43xx_d80211: Radio turned off
wmaster0: Selected rate control algorithm 'simple'
bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 5, MAC: 
00:90:4b:f2:30:e9)
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: firmware revision 127, patchlevel E, date 2005-04-18 
02:36:27
ssb: Switching to core 0
bcm43xx_d80211: InitVals (bcm43xx_initvalXX.fw) file-format error. 
Please fix your bcm43xx firmware files.
bcm43xx_d80211: core_up for active 802.11 core failed (-71)
bcm43xx_d80211: Virtual interface removed (type: 0x00000002, ID: 5, MAC: 
00:90:4b:f2:30:e9)
bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 5, MAC: 
00:90:4b:f2:30:e9)
ssb: Switching to core 1
bcm43xx_d80211: firmware revision 127, patchlevel E, date 2005-04-18 
02:36:27
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Radio turned on
bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: 32-bit DMA initialized
bcm43xx_d80211: Keys cleared
bcm43xx_d80211: Selected 802.11 core (phytype 2)
bcm43xx_d80211: ASSERTION FAILED (radio_attenuation < 10) at: 
drivers/net/wireless/d80211/bcm43xx/bcm43xx_phy.c:1490:bcm43xx_find_lopair()
wmaster0: Does not support passive scan, disabled
wlan0: no IPv6 routers present

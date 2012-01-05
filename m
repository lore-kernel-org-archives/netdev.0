From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] drivers: misc: Remove MISC_DEVICES config option
Date: Thu, 05 Jan 2012 17:42:54 -0600
Message-ID: <4F06357E.8050000@lwfinger.net>
References: <1325796541-11402-1-git-send-email-festevam@gmail.com> <4F0635FE.6050507@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam@gmail.com>, netdev@vger.kernel.org,
	gwingerde@gmail.com, davem@davemloft.net,
	bhutchings@solarflare.com, greg@kroah.com, arnd@arndb.de,
	linux-kernel@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55912 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758151Ab2AEXm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 18:42:59 -0500
In-Reply-To: <4F0635FE.6050507@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2012 05:45 PM, Randy Dunlap wrote:
> On 01/05/2012 12:49 PM, Fabio Estevam wrote:
>> MISC_DEVICES option alone does not select any kernel code and can cause dependency build warnings, such as:
>>
>> warning: (KS8851&&  AX88796_93CX6&&  RTL8180&&  RTL8187&&  ADM8211&&  RT2400PCI&&  RT2500PCI&&  RT61PCI&&  RT2800PCI&&  R8187SE) selects EEPROM_93CX6 which has unmet direct dependencies (MISC_DEVICES)
>>
>> Remove MISC_DEVICES option so that any dependency on this symbol is avoided.
>
> I thought that one purpose of MISC_DEVICES was to allow anyone to disable all
> options under it with one click (or keystroke), but since several drivers now
> "select MISC_DEVICES", that does not work.
>
> I would like to be able to disable all MISC_DEVICES, but since that
> does not currently function, this change is OK with me.

All of the drivers in the above list select *only* one driver in the 
MISC_DEVICES category. If that one were moved outside of MISC_DEVICES, most, if 
not all,problems would go away.

Larry

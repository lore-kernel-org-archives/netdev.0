From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: [PATCH 2/2] r8169: allow true forced mode setting
Date: Sat, 16 May 2009 21:57:10 +0200
Message-ID: <4A0F1A96.8070208@gmail.com>
References: <20090514214605.GB6374@electric-eye.fr.zoreil.com> <200905161450.38281.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vincent Steenhoute <vsteenhoute@novell.com>,
	Martin Michlmayr <tbm@cyrius.com>,
	Ivan Vecera <ivecera@redhat.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:65027 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752860AbZEPT5N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2009 15:57:13 -0400
Received: by ewy24 with SMTP id 24so3223910ewy.37
        for <netdev@vger.kernel.org>; Sat, 16 May 2009 12:57:13 -0700 (PDT)
In-Reply-To: <200905161450.38281.jdelvare@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

zOn 05/16/2009 02:50 PM, Jean Delvare wrote:

> If I read the code correctly, Realtek's driver (v6.010.00) only
> applies the quirk for RTL8169S and RTL8110S chips (what I have) and
> not the original RTL8169. Your code applies the quirk to all 3
> chips. Is this on purpose? Or am I missing something?

For reference, there it's the latest source code of Realtek drivers 
r8101/r8168/r8169 :

ftp://WebUser:DAx7h9V@202.65.194.212/cn/nic/r8101-1.012.00.tar.bz2
ftp://WebUser:DAx7h9V@202.65.194.212/cn/nic/r8168-8.012.00.tar.bz2
ftp://WebUser:DAx7h9V@202.65.194.212/cn/nic/r8169-6.010.00.tar.bz2

>> (...)
>> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_03) {
>> +		if ((speed == SPEED_100) && (autoneg != AUTONEG_ENABLE)) {
>> +			mdio_write(ioaddr, 0x17, 0x2138);
>> +			mdio_write(ioaddr, 0x0e, 0x0260);
>> +		} else {
>> +			mdio_write(ioaddr, 0x17, 0x2108);
>> +			mdio_write(ioaddr, 0x0e, 0x0000);
>> +		}
>> +	}
>> +
>>  	return 0;
>>  }

-thanks-

regards,

-- 
Polycommander, Erkowit, Urquiola, Andros Patria, Cason, Aegean Sea, Prestige, ...

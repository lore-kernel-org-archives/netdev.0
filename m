From: Ben Dooks <ben@simtec.co.uk>
Subject: Re: [patch 1/9] eeprom_93cx6: Add data direction control.
Date: Mon, 07 Dec 2009 12:24:13 +0000
Message-ID: <4B1CF3ED.4040305@simtec.co.uk>
References: <20091207121727.016092171@fluff.org.uk>	<20091207121827.433183360@fluff.org.uk> <20091207132141.1db65cd3@hyperion.delvare>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Wolfram Sang <w.sang@pengutronix.de>, doong.ping@micrel.com,
	tristram.ha@micrel.com, linux@simtec.co.uk
To: Jean Delvare <khali@linux-fr.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934713AbZLGMYK@vger.kernel.org>
In-Reply-To: <20091207132141.1db65cd3@hyperion.delvare>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Delvare wrote:
> On Mon, 07 Dec 2009 12:17:28 +0000, Ben Dooks wrote:
>> Some devices need to know if the data is to be output or read, so add a
>> data direction into the eeprom structure to tell the driver whether the
>> data line should be driven.
>>
>> The user in this case is the Micrel KS8851 which has a direction
>> control for the EEPROM data line and thus needs to know whether
>> to drive it (writing) or to tristate it for receiving.
>>
>> Signed-off-by: Ben Dooks <ben@simtec.co.uk>
>> Cc: Wolfram Sang <w.sang@pengutronix.de>
>> Cc: Jean Delvare <khali@linux-fr.org>
>> Cc: Linux Kernel <linux-kernel@vger.kernel.org>
> 
> FYI, I will not be reviewing this patch nor any other patch to the
> eeprom_93cx6 driver. I have no clue what these devices are, no access
> to any and no interest in them either.

Ok, scripts/get_maintainer.pl came up with yourself, Wolfram and linux-kernel
as the people to send this to.

-- 
Ben Dooks, Design & Software Engineer, Simtec Electronics

http://www.simtec.co.uk/

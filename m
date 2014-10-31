From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethtool: Return -EOPNOTSUPP if user space tries
 to read EEPROM with lengh 0
Date: Fri, 31 Oct 2014 16:13:06 -0400 (EDT)
Message-ID: <20141031.161306.1209095823862991107.davem@davemloft.net>
References: <1414727415-5470-1-git-send-email-linux@roeck-us.net>
	<20141031035635.GC4082@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141031035635.GC4082@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri, 31 Oct 2014 04:56:35 +0100

> On Thu, Oct 30, 2014 at 08:50:15PM -0700, Guenter Roeck wrote:
>> If a driver supports reading EEPROM but no EEPROM is installed in the system,
>> the driver's get_eeprom_len function returns 0. ethtool will subsequently
>> try to read that zero-length EEPROM anyway. If the driver does not support
>> EEPROM access at all, this operation will return -EOPNOTSUPP. If the driver
>> does support EEPROM access but no EEPROM is installed, the operation will
>> return -EINVAL. Return -EOPNOTSUPP in both cases for consistency.
>> 
>> Signed-off-by: Guenter Roeck <linux@roeck-us.net>
> 
> root@dir665:~# ethtool -e lan4
> Cannot get EEPROM data: Operation not supported
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks everyone.

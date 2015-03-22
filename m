From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/18] net: dsa: mv88e6xxx: Add Hardware bridging
 support
Date: Sun, 22 Mar 2015 18:24:07 -0400 (EDT)
Message-ID: <20150322.182407.1915654260904903040.davem@davemloft.net>
References: <1426952815-4642-1-git-send-email-linux@roeck-us.net>
	<1426952815-4642-9-git-send-email-linux@roeck-us.net>
	<20150322200600.GD15025@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@roeck-us.net, netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org
To: andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150322200600.GD15025@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 22 Mar 2015 21:06:00 +0100

> Hi Guenter
> 
>> +static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
>> +{
>> +	int ret;
>> +
>> +	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x01, fid);
>> +	if (ret < 0)
>> +		return ret;
> 
> Please could you check this. I think register 0x01 here is wrong. I
> think you want 0x0b, the ATU Operations register?

Just want to mention that register mnenomics would have made this
bug more obvious :-)

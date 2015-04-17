From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: dsa: use DEVICE_ATTR_RW to declare temp1_max
Date: Fri, 17 Apr 2015 15:59:16 -0400 (EDT)
Message-ID: <20150417.155916.1229306319675431834.davem@davemloft.net>
References: <1429297945-26651-1-git-send-email-vivien.didelot@savoirfairelinux.com>
	<20150417194006.GA9538@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150417194006.GA9538@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Fri, 17 Apr 2015 12:40:06 -0700

> On Fri, Apr 17, 2015 at 03:12:25PM -0400, Vivien Didelot wrote:
>> Since commit da4759c (sysfs: Use only return value from is_visible for
>> the file mode), it is possible to reduce the permissions of a file.
>> 
>> So declare temp1_max with the DEVICE_ATTR_RW macro and remove the write
>> permission in dsa_hwmon_attrs_visible if set_temp_limit isn't provided.
>> 
>> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> 
> Looks good.
> 
> Reviewed-by: Guenter Roeck <linux@roeck-us.net>

Applied, thanks everyone.

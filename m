From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/2] net: dsa: use DEVICE_ATTR_RW to declare temp1_max
Date: Thu, 16 Apr 2015 21:55:49 +0300
Message-ID: <553005B5.9000101@cogentembedded.com>
References: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429209499-2447-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 04/16/2015 09:38 PM, Vivien Didelot wrote:

> Since commit da4759c, sysfs will only use the permissions returned by

    Please also specify that commit's summary line in parens.

> is_visible, instead of OR'ing them with the default file mode.

> This allows us to declare temp1_max with the DEVICE_ATTR_RW macro and
> just return the desired permissions for the hwmon sysfs attributes in
> dsa_hwmon_attrs_visible.

> Also, allow temp1_max to be write-only if set_temp_limit is provided,
> but not get_temp_limit.

> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

WBR, Sergei

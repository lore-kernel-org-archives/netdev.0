From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] wireless: Convert mwifiex/pcie to dev_pm_ops from
 legacy pm_ops
Date: Wed, 3 Jul 2013 14:46:39 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430EA2E06715@SC-VEXCH1.marvell.com>
References: <1372870030-2596-1-git-send-email-shuah.kh@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shuahkhan@gmail.com" <shuahkhan@gmail.com>
To: Shuah Khan <shuah.kh@samsung.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "hauke@hauke-m.de" <hauke@hauke-m.de>,
	"lars@metafoo.de" <lars@metafoo.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372870030-2596-1-git-send-email-shuah.kh@samsung.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Convert the mwifiex/pci driver to use dev_pm_ops for power management and
> remove Legacy PM handling. This change re-uses existing suspend and resume
> interfaces for dev_pm_ops, and changes CONFIG_PM ifdefs to CONFIG_PM_SLEEP
> as the driver does not support run-time PM.
> 
> Signed-off-by: Shuah Khan <shuah.kh@samsung.com>

Acked-by: Bing Zhao <bzhao@marvell.com>

Thanks,
Bing

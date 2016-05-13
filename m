From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net-next 07/11] net: hns: dsaf adds support of acpi
Date: Fri, 13 May 2016 16:12:16 +0300
Message-ID: <1463145136.17131.344.camel@linux.intel.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1463127557-90824-8-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, andrew@lunn.ch, geliangtang@163.com,
	ivecera@redhat.com, fengguang.wu@intel.com,
	charles.chenxin@huawei.com, haifeng.wei@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	rjw@rjwysocki.net, lenb@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-8-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
> From: Kejian Yan <yankejian@huawei.com>
> 
> Dsaf needs to get configuration parameter by ACPI, so this patch add
> support of ACPI.
> 

Looks like at some point better to split driver to core part, and PCI
and ACPI/DT/platform code.

Too many changes where IS_ENABLED() involved shows as I can imagine bad
architecture / split of the driver.

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy

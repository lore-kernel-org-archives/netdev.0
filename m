From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [patch net-next 06/11] ACPI: bus: move acpi_match_device_ids()
 to linux/acpi.h
Date: Fri, 13 May 2016 16:15:12 +0300
Message-ID: <1463145312.17131.347.camel@linux.intel.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
	 <1463127557-90824-7-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arnd@arndb.de, andrew@lunn.ch, geliangtang@163.com,
	ivecera@redhat.com, fengguang.wu@intel.com,
	charles.chenxin@huawei.com, haifeng.wei@huawei.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxarm@huawei.com
To: Yisen Zhuang <Yisen.Zhuang@huawei.com>, davem@davemloft.net,
	rjw@rjwysocki.net, lenb@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463127557-90824-7-git-send-email-Yisen.Zhuang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
> From: Hanjun Guo <hanjun.guo@linaro.org>
>=20
> acpi_match_device_ids() will be used for drivers to match
> different hardware versions, it will be compiled in non-ACPI
> case, but acpi_match_device_ids() in acpi_bus.h and it can
> only be used in ACPI case, so move it to linux/acpi.h and
> introduce a stub function for it.

I somehow doubt this is right move.

Like I said in the previous comment the architectural split might make
this a bit better.

You might use=C2=A0

#ifdef IS_ENABLED(CONFIG_ACPI)
#else
#endif

only once to some big part of code. If kernel is build without ACPI
support you even will not have this in your driver at all.

--=C2=A0
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy

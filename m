From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.2 01/22] fjes: Introduce FUJITSU Extended Socket
 Network Device driver
Date: Thu, 20 Aug 2015 15:49:01 -0700 (PDT)
Message-ID: <20150820.154901.1696097888673162441.davem@davemloft.net>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	dvhart@infradead.org, rkhan@redhat.com,
	alexander.h.duyck@redhat.com, linux-acpi@vger.kernel.org,
	joe@perches.com, sergei.shtylyov@cogentembedded.com,
	stephen@networkplumber.org, yasu.isimatu@gmail.com
To: izumi.taku@jp.fujitsu.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Thu, 20 Aug 2015 17:46:05 +0900

> +obj-$(CONFIG_FUJITSU_ES) += fjes.o
> +
> +fjes-objs := fjes_main.o
> +

Please do not have trailing empty lines in any files you add
or edit, 'git' warns about this even when applying patches.

> +static int fjes_acpi_add(struct acpi_device *device)
> +{
> +	acpi_status status;
> +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL};
> +	union acpi_object *str;
> +	char str_buf[sizeof(FJES_ACPI_SYMBOL) + 1];
> +	int result;
> +	struct platform_device *plat_dev;

Please order your local variables in "reverse christmas tree" order, which
means longer lines come before shorter ones.

Please correct this problem in your entire submission, as I am not going
to point out each and every other place where this problem exists.

From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Thu, 26 Mar 2015 12:20:53 +0100
Message-ID: <20150326112053.GB19973@ribalta.ger.corp.intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Robert,

Another comment:

On Tue, Feb 24, 2015 at 12:01:52PM +0200, Robert Dolca wrote:
> +static struct i2c_device_id fdp_nci_i2c_id_table[] = {
> +	{"INT339A", 0},
> +	{}
> +};
> +
> +MODULE_DEVICE_TABLE(i2c, fdp_nci_i2c_id_table);
> +
> +
> +static const struct acpi_device_id fdp_nci_i2c_acpi_match[] = {
> +	{"INT339A", 0},
> +	{}
> +};
Why don't we have a MODULE_DEVICE_TABLE(acpi, fdp_nci_i2c_acpi_match);
here ?

Cheers,
Samuel.

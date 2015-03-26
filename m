From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Thu, 26 Mar 2015 15:45:55 +0200
Message-ID: <20150326134555.GL1878@lahna.fi.intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 24, 2015 at 12:01:52PM +0200, Robert Dolca wrote:
> +static struct i2c_device_id fdp_nci_i2c_id_table[] = {
> +	{"INT339A", 0},

If this is ACPI only device you can remove the above line.

> +	{}
> +};
> +
> +MODULE_DEVICE_TABLE(i2c, fdp_nci_i2c_id_table);

And this as well.

> +
> +
> +static const struct acpi_device_id fdp_nci_i2c_acpi_match[] = {
> +	{"INT339A", 0},
> +	{}
> +};
> +
> +static struct i2c_driver fdp_nci_i2c_driver = {
> +	.driver = {
> +		   .name = FDP_NCI_I2C_DRIVER_NAME,
> +		   .owner  = THIS_MODULE,
> +		   .acpi_match_table = ACPI_PTR(fdp_nci_i2c_acpi_match),
> +		  },
> +	.id_table = fdp_nci_i2c_id_table,
> +	.probe = fdp_nci_i2c_probe,
> +	.remove = fdp_nci_i2c_remove,
> +};

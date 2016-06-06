From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 16:40:36 +0200
Message-ID: <20160606144036.GA30948@lunn.ch>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
 <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com, Greg KH <gregkh@linuxfoundation.org>
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465222521-7217-2-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +	/* returns _AUXMAC_#AABBCCDDEEFF# */
> +	status = acpi_evaluate_object(NULL, "\\_SB.AMAC", NULL, &buffer);
> +	obj = (union acpi_object *)buffer.pointer;
> +	if (ACPI_SUCCESS(status)) {
> +		if (obj->type != ACPI_TYPE_BUFFER ||
> +		    obj->string.length != 0x17) {
> +			pr_warn("r8152: get_passthru_addr: Invalid buffer");

Please don't use pr_warn() when you can use the better alternatives
like dev_warn().

     Andrew

From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Tue, 24 Feb 2015 11:33:10 +0100
Message-ID: <1424773990.2192.27.camel@sipsolutions.net>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
	 <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
	 (sfid-20150224_110328_126821_85458A24)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-nfc@ml01.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424772112-27399-9-git-send-email-robert.dolca@intel.com> (sfid-20150224_110328_126821_85458A24)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I have no idea about NFC, but 

> +config NFC_FDP
> +	tristate "Intel FDP NFC driver"
> +	depends on NFC_NCI
> +	select CRC_CCITT
> +	default n
> +	---help---
> +	  Intel FDP core driver.
> +	  This is a driver based on the NCI NFC kernel layers.
> +
> +	  To compile this driver as a module, choose m here. The module will
> +	  be called pn547.

this seems like a copy/paste error? Certainly it's called fdp?

johannes

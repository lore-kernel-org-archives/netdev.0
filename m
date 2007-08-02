From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Thu, 02 Aug 2007 02:23:17 -0700 (PDT)
Message-ID: <20070802.022317.66176729.davem@davemloft.net>
References: <1186002023.18322.7.camel@dell>
	<200708021005.45773.joachim.deguara@amd.com>
	<200708021115.10812.joachim.deguara@amd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, linux-acpi@vger.kernel.org
To: joachim.deguara@amd.com
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <200708021115.10812.joachim.deguara@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Joachim Deguara" <joachim.deguara@amd.com>
Date: Thu, 2 Aug 2007 11:15:05 +0200

> Seams like even if powersave shuts down the network that the device should 
> still work after a suspend to ram, so who is at fault here?

It's a good question.

The pci_enable() is done on the PCI device at probe time, at least in
the tg3 driver, and with such a model restoring and saving of PCI
config space should not be dependant upon whether the netdev is
running or not.

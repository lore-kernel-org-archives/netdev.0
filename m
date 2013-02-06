From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] rtlwifi: rtl8192cu: Fix NULL dereference BUG when using
 new_id
Date: Wed, 6 Feb 2013 00:18:24 +0000
Message-ID: <1360109904.2857.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <1360108823-5141-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linville@tuxdriver.com>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, Stable <stable@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1360108823-5141-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-02-05 at 18:00 -0600, Larry Finger wrote:
> When the new_id entry is used for a foreign USB device, rtlwifi BUGS with
> a NULL pointer dereference.
[...]

So set no_dynamic_id in the usb_driver structures.

(But I wonder why USB behaves differently from PCI, which requires that
the dynamic ID's driver_data value (defaulting to 0) matches a value
used in a static ID entry.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

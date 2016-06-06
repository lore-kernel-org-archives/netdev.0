From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v3] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Mon, 6 Jun 2016 07:40:09 -0700
Message-ID: <20160606144009.GB4758@kroah.com>
References: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hayeswang@realtek.com, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com
To: Mario Limonciello <mario_limonciello@dell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465222521-7217-1-git-send-email-mario_limonciello@dell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 09:15:20AM -0500, Mario Limonciello wrote:
> Since this is a Realtek feature, I feel this shouldn't be moved into a platform
> MAC address lookup.  The code should only be run when the correct Realtek device
> is plugged in.
> 
> Changes from v2:
>  * Only apply to RTL8153-AD w/ eFuse pass through mac address pass thru
>    bit set.
>  * Drop matching DMI information on Dell.  Although this is implemented on
>    Dell, this is a Realtek feature that may may be implemented on other
>    OEMs as well.
>  * Test that pass through MAC address is valid, fall back to HW address if
>    invalid.
>  * Don't track status of which device has MAC pass through activated.
>  - Expected experience is that if two docks (RTL8153-AD's w/ mac pass thru
>    bit set) were plugged in both should have MAC pass through activated.

cover letters for single-patch submissions is overkill and confusing,
please don't.

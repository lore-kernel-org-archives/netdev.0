From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] rtlwifi: rtl8192cu: Fix NULL dereference BUG when using
 new_id
Date: Tue, 05 Feb 2013 18:44:22 -0600
Message-ID: <5111A766.70006@lwfinger.net>
References: <1360108823-5141-1-git-send-email-Larry.Finger@lwfinger.net> <1360109904.2857.36.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:45446 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753302Ab3BFAoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 19:44:24 -0500
In-Reply-To: <1360109904.2857.36.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2013 06:18 PM, Ben Hutchings wrote:
> On Tue, 2013-02-05 at 18:00 -0600, Larry Finger wrote:
>> When the new_id entry is used for a foreign USB device, rtlwifi BUGS with
>> a NULL pointer dereference.
> [...]
>
> So set no_dynamic_id in the usb_driver structures.
>
> (But I wonder why USB behaves differently from PCI, which requires that
> the dynamic ID's driver_data value (defaulting to 0) matches a value
> used in a static ID entry.)

I don't know why USB differs from PCI, but we do need the dynamic ID here as 
there are always new IDs being issued. One of the criteria for adding the ID to 
the table is that it works OK with dynamic addition. These devices are 
frequently reported by users that do not have the skills to build their own kernel.

Larry

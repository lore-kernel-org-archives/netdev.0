From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 2/6] d80211: create "wifi.h" to define WIFI OUIs
Date: Thu, 14 Dec 2006 11:31:50 +0100
Message-ID: <20061214113150.54523e61@griffin.suse.cz>
References: <20061214040216.GA10652@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51814 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751924AbWLNKbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 05:31:40 -0500
To: yi.zhu@intel.com
In-Reply-To: <20061214040216.GA10652@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Dec 2006 12:02:16 +0800, Zhu Yi wrote:
> --- /dev/null
> +++ b/net/d80211/wifi.h
> @@ -0,0 +1,28 @@
> +/*
> + * This file defines Wi-Fi(r) OUIs for 80211.o
> + * Copyright 2006, Zhu Yi <yi.zhu@intel.com>  Intel Corp.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License version 2 as
> + * published by the Free Software Foundation.
> + */
> +
> +#ifndef D802_11_WIFI_H
> +#define D802_11_WIFI_H
> +
> +/* WI-FI Alliance OUI Type and Subtype */
> +enum wifi_oui_type {
> +	WIFI_OUI_TYPE_WPA = 1,
> +	WIFI_OUI_TYPE_WMM = 2,
> +	WIFI_OUI_TYPE_WSC = 4,
> +	WIFI_OUI_TYPE_PSD = 6,
> +};
> +
> +enum wifi_oui_stype_wmm {
> +	WIFI_OUI_STYPE_WMM_INFO = 0,
> +	WIFI_OUI_STYPE_WMM_PARAM = 1,
> +	WIFI_OUI_STYPE_WMM_TSPEC = 2,
> +};
> +
> +
> +#endif /* D802_11_WIFI_H */

AFAIK "wifi" is a trademark and we want to avoid using it. "wlan" seems
to be a better alternative for the prefixes. Also, I don't see a reason
for a separate header file here.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs

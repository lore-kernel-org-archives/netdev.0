From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Thu, 23 Mar 2017 09:46:47 +0100
Message-ID: <1490258807.25543.0.camel@suse.com>
References: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Greg Ungerer <gerg@linux-m68k.org>, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53789 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932252AbdCWIrj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Mar 2017 04:47:39 -0400
In-Reply-To: <1490232332-19274-1-git-send-email-gerg@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 23.03.2017, 11:25 +1000 schrieb Greg Ungerer:
> Add support for the net stats64 counters to the usbnet core and then to
> the qmi_wwan driver.
> 
> This is a strait forward addition of 64bit counters for RX and TX packets
> and byte counts. It is done in the same style as for the other net drivers
> that support stats64.
> 
> The bulk of the change is to the usbnet core. Then it is trivial to use
> that in the qmi_wwan.c driver. It would be very simple to extend this
> support to other usbnet based drivers.
> 
> The motivation to add this is that it is not particularly difficult to
> get the RX and TX byte counts to wrap on 32bit platforms.

Hi,

you need to export the symbol usbnet_get_stats64
Other than that it looks good.

	Regards
		Oliver
